defmodule Caju.Membership do
  @moduledoc """
  The Membership context.
  """

  import Ecto.Query, warn: false
  alias Caju.Membership
  alias Caju.Accounts
  alias Caju.Repo

  alias Caju.Membership.Organization

  @type list_opt() :: {:filter_by_domain, String.t()}

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  alias Caju.Membership.Site

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites do
    Repo.all(Site)
  end

  def get_by_domain(name) do
    Repo.get_by(Site, name: name)
  end

  def get_by_domain!(name) do
    Repo.get_by!(Site, name: name)
  end

  def is_member?(user_id, site) do
    role(user_id, site) !== nil
  end

  def role(user_id, site) do
    Repo.one(
      from(sm in Membership.Membership,
        where: sm.user_id == ^user_id and sm.site_id == ^site.id,
        select: sm.role
      )
    )
  end

  def get_for_user!(user_id, name, roles \\ [:owner, :admin, :viewer]) do
    if :super_admin in roles and Accounts.is_super_admin?(user_id) do
      get_by_domain(name)
    else
      user_id
      |> get_for_user_q(name, List.delete(roles, :super_admin))
      |> Repo.one()
    end
  end

  defp get_for_user_q(user_id, site_id, roles) do
    from(s in Site,
      join: sm in Membership.Membership,
      on: sm.site_id == s.id,
      where: sm.user_id == ^user_id,
      where: sm.role in ^roles,
      where: s.id == ^site_id,
      select: s
    )
  end

  # @spec list(Accounts.User.t(), map(), [list_opt()]) :: Scrivener.Page.t()
  # def list(user, _pagination_params, opts \\ []) do
  #   _domain_filter = Keyword.get(opts, :filter_by_domain)

  #   from(s in Site,
  #     inner_join: sm in assoc(s, :memberships),
  #     on: sm.user_id == ^user.id,
  #     select: s,
  #     order_by: [asc: s.name],
  #     preload: [memberships: sm]
  #   )
  # end

  @spec list_with_invitations(Accounts.User.t(), map(), [list_opt()]) :: Scrivener.Page.t()
  def list_with_invitations(user, pagination_params, opts \\ []) do
    _domain_filter = Keyword.get(opts, :filter_by_domain)

    result =
      from(s in Site,
        left_join: i in assoc(s, :invitations),
        on: i.email == ^user.email,
        left_join: sm in assoc(s, :memberships),
        on: sm.user_id == ^user.id,
        where: not is_nil(sm.id) or not is_nil(i.id),
        select: %{
          s
          | entry_type:
              selected_as(
                fragment(
                  """
                  CASE
                    WHEN ? IS NOT NULL THEN 'invitation'
                    ELSE 'site'
                  END
                  """,
                  i.id
                ),
                :entry_type
              )
        },
        order_by: [asc: selected_as(:entry_type), asc: s.name],
        preload: [memberships: sm, invitations: i]
      )
      |> Repo.paginate(pagination_params)

    # Populating `site` preload on `invitation`
    # without requesting it from database.
    # Necessary for invitation modals logic.
    entries =
      Enum.map(result.entries, fn
        %{invitations: [invitation]} = site ->
          site = %{site | invitations: [], memberships: []}
          invitation = %{invitation | site: site}
          %{site | invitations: [invitation]}

        site ->
          site
      end)

    %{result | entries: entries}
  end

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(123)
      %Site{}

      iex> get_site!(456)
      ** (Ecto.NoResultsError)

  """
  def get_site!(id), do: Repo.get!(Site, id)

  @doc """
  Creates a site.

  ## Examples

      iex> create_site(%{field: value})
      {:ok, %Site{}}

      iex> create_site(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_site(user, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:site, Site.new(params))
    |> Ecto.Multi.insert(:site_membership, fn %{site: site} ->
      Membership.Membership.new(site, user)
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a site.

  ## Examples

      iex> update_site(site, %{field: new_value})
      {:ok, %Site{}}

      iex> update_site(site, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a site.

  ## Examples

      iex> delete_site(site)
      {:ok, %Site{}}

      iex> delete_site(site)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.

  ## Examples

      iex> change_site(site)
      %Ecto.Changeset{data: %Site{}}

  """
  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end
end
