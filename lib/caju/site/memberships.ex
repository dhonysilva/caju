defmodule Caju.Site.Memberships do
  import Ecto.Query, only: [from: 2]
  alias Caju.Repo

  defdelegate accept_invitation(invitation_id, user), to: Caju.Site.Memberships.AcceptInvitation

  defdelegate create_invitation(site, inviter, invitee_email, role),
    to: Caju.Site.Memberships.CreateInvitation

  def any_or_pending?(user) do
    invitation_query =
      from(i in Caju.Membership.Invitation,
        where: i.email == ^user.email,
        select: 1
      )

    from(sm in Caju.Membership.Membership,
      where: sm.user_id == ^user.id or exists(invitation_query),
      select: 1
    )
    |> Repo.exists?()
  end
end
