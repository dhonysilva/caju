defmodule Caju.Site.Memberships.CreateInvitation do
  @moduledoc """
  Service for inviting new or existing users to a sites.
  """
  alias Caju.Membership
  alias Caju.Membership.Invitation
  import Ecto.Query

  def create_invitation(site, inviter, invite_email, role) do
    Caju.Repo.transaction(fn ->
      do_invite(site, inviter, invite_email, role)
    end)
  end

  defp do_invite(site, inviter, invitee_email, role, opts \\ []) do
    attrs = %{email: invitee_email, role: role, site_id: site.id, inviter_id: inviter.id}

    with site <- Caju.Repo.preload(site, :owner),
         :ok <- check_invitation_permissions(site, inviter, role, opts),
         invitee <- Caju.Accounts.find_user_by(email: invitee_email),
         :ok <- ensure_new_membership(site, invitee, role),
         %Ecto.Changeset{} = changeset <- Invitation.new(attrs),
         {:ok, invitation} <- Caju.Repo.insert(changeset) do
      send_invitation_email(invitation, invitee)
      invitation
    else
      {:error, cause} -> Caju.Repo.rollback(cause)
    end
  end

  defp check_invitation_permissions(site, inviter, requested_role, opts) do
    check_permissions? = Keyword.get(opts, :check_permissions, true)

    if check_permissions? do
      required_roles = if requested_role == :owner, do: [:owner], else: [:admin, :owner]

      membership_query =
        from(m in Membership.Membership,
          where: m.user_id == ^inviter.id and m.site_id == ^site.id and m.role in ^required_roles
        )

      if Caju.Repo.exists?(membership_query), do: :ok, else: {:error, :forbidden}
    else
      :ok
    end
  end

  defp send_invitation_email(_invitation, _invitee) do
    # invitation = Caju.Repo.preload(invitation, [:site, :inviter])

    # email =
    #   case {invitee, invitation.role} do
    #     {invitee, :owner} -> CajuWeb.Email.ownership_transfer_request(invitation, invitee)
    #     {nil, _role} -> CajuWeb.Email.new_user_invitation(invitation)
    #     {%User{}, _role} -> CajuWeb.Email.exisitin_user_invitation(invitation)
    #   end

    # Caju.Mailer.send(email)

    :ok
  end

  defp ensure_new_membership(_site, _invitee, :owner) do
    :ok
  end

  defp ensure_new_membership(site, invitee, _role) do
    if invitee && Membership.is_member?(invitee.id, site) do
      {:error, :already_a_member}
    else
      :ok
    end
  end
end
