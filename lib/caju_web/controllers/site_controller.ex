defmodule CajuWeb.SiteController do
  use CajuWeb, :controller

  use Caju.Repo
  alias Caju.Membership
  alias Caju.Membership.Site

  plug CajuWeb.AuthorizeSiteAccess,
       [:owner, :admin, :super_admin] when action not in [:new, :create_site]

  def index(conn, _params) do
    sites = Membership.list_sites()

    conn
    |> put_layout(html: :site_settings)
    |> render(:index, sites: sites)
  end

  def new(conn, _params) do
    changeset = Membership.change_site(%Site{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"site" => site_params}) do
    user = conn.assigns[:current_user]

    case Membership.create_site(user, site_params) do
      {:ok, %{site: site}} ->
        conn
        |> put_flash(:info, "Site created successfully.")
        |> redirect(to: ~p"/sites/#{site}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    render(conn, :show, site: site)
  end

  def edit(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    changeset = Membership.change_site(site)
    render(conn, :edit, site: site, changeset: changeset)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = Membership.get_site!(id)

    case Membership.update_site(site, site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site updated successfully.")
        |> redirect(to: ~p"/sites/#{site}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, site: site, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    {:ok, _site} = Membership.delete_site(site)

    conn
    |> put_flash(:info, "Site deleted successfully.")
    |> redirect(to: ~p"/sites")
  end

  # Functions related to Settings

  def settings(conn, %{"website" => website}) do
    redirect(conn, to: ~p"/#{website}/settings/general")
  end

  def settings_general(conn, _params) do
    site = conn.assigns[:site]

    conn
    |> put_layout(html: :site_settings)
    |> render(:settings_general,
      site: site,
      changeset: Caju.Membership.Site.changeset(site, %{})
    )
  end

  def settings_people(conn, _params) do
    site =
      conn.assigns[:site]
      |> Repo.preload(memberships: :user, invitations: [])

    conn
    # |> render("settings_people.html",
    #   site: site,
    #   dogfood_page_path: "/:dashboard/settings/people",
    #   layout: {SiteWeb.LayoutView, "site_settings.html"}
    # )
    |> put_layout(html: :site_settings)
    |> render(:settings_people, site: site)
  end
end
