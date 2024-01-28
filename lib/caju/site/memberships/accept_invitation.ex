defmodule Caju.Site.Memberships.AcceptInvitation do
  use Caju

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Caju.Repo

  require Logger

  @spec accept_invitation(String.t(), Caju.Accounts.User.t()) ::
          {:ok, Caju.Membership.Membership.t()}
          | {:error,
             :invitation_not_found
             | Billing.Quota.over_limits_error()
             | Ecto.Changeset.t()
             | :no_plan}
  def accept_invitation(invitation_id, user) do
    IO.inspect(invitation_id, label: "De dentro do metodo accept_invitation")

    with {:ok, invitation} <-
           Caju.Site.Memberships.Invitations.find_for_user(invitation_id, user) do
      if invitation.role == :owner do
        do_accept_ownership_transfer(invitation, user)
      else
        do_accept_invitation(invitation, user)
      end
    end
  end

  defp do_accept_ownership_transfer(invitation, user) do
    membership = get_or_create_membership(invitation, user)
    site = Repo.preload(invitation.site, :owner)

    with :ok <- Invitations.ensure_can_take_ownership(site, user) do
      site
      |> add_and_transfer_ownership(membership, user)
      |> Multi.delete(:invitation, invitation)
      |> finalize_invitation(invitation)
    end
  end

  defp do_accept_invitation(invitation, user) do
    membership = get_or_create_membership(invitation, user)

    invitation
    |> add(membership, user)
    |> finalize_invitation(invitation)
  end

  defp finalize_invitation(multi, invitation) do
    case Repo.transaction(multi) do
      {:ok, changes} ->
        notify_invitation_accepted(invitation)

        membership = Repo.preload(changes.membership, [:site, :user])

        {:ok, membership}

      {:error, _operation, error, _changes} ->
        {:error, error}
    end
  end

  defp add_and_transfer_ownership(site, membership, user) do
    Multi.new()
    |> downgrade_previous_owner(site, user)
    |> Multi.insert_or_update(:membership, membership)
  end

  # If there's an existing membership, we DO NOT change the role
  # to avoid accidental role downgrade.
  defp add(invitation, membership, _user) do
    if membership.data.id do
      Multi.new()
      |> Multi.put(:membership, membership.data)
      |> Multi.delete(:invitation, invitation)
    else
      Multi.new()
      |> Multi.insert(:membership, membership)
      |> Multi.delete(:invitation, invitation)
    end
  end

  defp get_or_create_membership(invitation, user) do
    case Repo.get_by(Caju.Membership.Membership, user_id: user.id, site_id: invitation.site.id) do
      nil -> Caju.Membership.Membership.new(invitation.site, user)
      membership -> membership
    end
    |> Caju.Membership.Membership.set_role(invitation.role)
  end

  defp get_or_create_owner_membership(site, user) do
    case Repo.get_by(Caju.Membership.Membership, user_id: user.id, site_id: site.id) do
      nil -> Caju.Membership.Membership.new(site, user)
      membership -> membership
    end
    |> Caju.Membership.Membership.set_role(:owner)
  end

  # If the new owner is the same as old owner, we do not downgrade them
  # to avoid leaving site without an owner!
  defp downgrade_previous_owner(multi, site, new_owner) do
    new_owner_id = new_owner.id

    previous_owner =
      Repo.one(
        from(
          sm in Caju.Membership.Membership,
          where: sm.site_id == ^site.id,
          where: sm.role == :owner
        )
      )

    case previous_owner do
      %{user_id: ^new_owner_id} ->
        Multi.put(multi, :previous_owner_membership, previous_owner)

      nil ->
        Logger.warning(
          "Transferring ownership from a site with no owner: #{site.domain} " <>
            ", new owner ID: #{new_owner_id}"
        )

        Multi.put(multi, :previous_owner_membership, nil)

      previous_owner ->
        Multi.update(
          multi,
          :previous_owner_membership,
          Caju.Membership.Membership.set_role(previous_owner, :admin)
        )
    end
  end

  defp notify_invitation_accepted(%Caju.Membership.Invitation{role: :owner} = invitation) do
    # PlausibleWeb.Email.ownership_transfer_accepted(invitation)
    # |> Plausible.Mailer.send()
  end

  defp notify_invitation_accepted(invitation) do
    # PlausibleWeb.Email.invitation_accepted(invitation)
    # |> Plausible.Mailer.send()
  end
end
