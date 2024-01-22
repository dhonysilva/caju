defmodule CajuWeb.Site.MembershipController do
  use CajuWeb, :controller
  use Caju.Repo
  alias Caju.Membership

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

    # render(
    #   conn,
    #   "invite_member_form.html",
    #   site: site,
    #   layout: {CajuWeb.LayoutView, "focus.html"}
    # )
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
end
