defmodule Caju.Site.Memberships.Invitations do
  use Caju

  alias Caju.Repo

  @spec find_for_user(String.t(), Caju.Accounts.User.t()) ::
          {:ok, Caju.Membership.Invitation.t()} | {:error, :invitation_not_found}
  def find_for_user(invitation_id, user) do
    invitation =
      Caju.Membership.Invitation
      |> Repo.get_by(invitation_id: invitation_id, email: user.email)
      |> Repo.preload([:site, :inviter])

    if invitation do
      {:ok, invitation}
    else
      {:error, :invitation_not_found}
    end
  end
end
