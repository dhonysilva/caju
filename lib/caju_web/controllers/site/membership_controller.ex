defmodule CajuWeb.Site.MembershipController do
  use CajuWeb, :controller
  use Caju.Repo
  alias Caju.Membership
  alias Caju.Site.Memberships

  @only_owner_is_allowed_to [:transfer_ownership_form, :transfer_ownership]

  plug CajuWeb.AuthorizeSiteAccess, [:owner] when action in @only_owner_is_allowed_to

  plug CajuWeb.AuthorizeSiteAccess,
       [:owner, :admin] when action not in @only_owner_is_allowed_to

  def invite_member_form(conn, _params) do
    site =
      conn.assigns.current_user.id
      |> Membership.get_for_user!(conn.assigns.site.id)
      |> Caju.Repo.preload(:owner)

    conn
    |> put_layout(html: :focus)
    |> render(:invite_member_form, site: site)
  end

  def invite_member(conn, %{"email" => email, "role" => role}) do
    site_id = conn.assigns[:site].id

    site = Membership.get_for_user!(conn.assigns[:current_user].id, site_id)

    case Memberships.create_invitation(site, conn.assigns.current_user, email, role) do
      {:ok, invitation} ->
        conn
        |> put_flash(
          :success,
          "#{email} has been invited to #{site_id} as #{invitation.role}"
        )
        |> redirect(to: ~p"/#{site_id}/settings/people")

      {:error, :already_a_member} ->
        render(conn, "invite_member_form.html",
          error: "Cannot send invite because #{email} is already a member of #{site.domain}",
          site: site,
          layout: {PlausibleWeb.LayoutView, "focus.html"},
          skip_plausible_tracking: true
        )

      {:error, {:over_limit, limit}} ->
        render(conn, "invite_member_form.html",
          error:
            "Your account is limited to #{limit} team members. You can upgrade your plan to increase this limit.",
          site: site,
          layout: {PlausibleWeb.LayoutView, "focus.html"},
          skip_plausible_tracking: true
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        error_msg =
          case changeset.errors[:invitation] do
            {"already sent", _} ->
              "This invitation has been already sent. To send again, remove it from pending invitations first."

            _ ->
              "Something went wrong."
          end

        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: ~p"/#{site_id}/settings/people")
    end
  end
end
