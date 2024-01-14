defmodule CajuWeb.MembershipController do
  use CajuWeb, :controller
  use Caju.Repo
  alias Caju.Membership

  def invite_member_form(conn, _params) do
    site =
      conn.assigns.current_user.id
      |> Membership.get_for_user!(conn.assigns.site.domain)
      |> Caju.Repo.preload(:owner)

    render(
      conn,
      "invite_member_form.html",
      site: site,
      layout: {CajuWeb.LayoutView, "focus.html"}
    )
  end
end
