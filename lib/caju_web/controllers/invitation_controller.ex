defmodule CajuWeb.InvitationController do
  use CajuWeb, :controller

  plug CajuWeb.RequireAccountPlug
  plug CajuWeb.AuthorizeSiteAccess, [:owner, :admin] when action in [:remove_invitation]

  def accept_invitation(conn, %{"invitation_id" => invitation_id}) do
    IO.inspect(conn, label: "Cheguei aqui no accept_invitation")

    case Caju.Site.Memberships.accept_invitation(invitation_id, conn.assigns.current_user) do
      {:ok, membership} ->
        conn
        |> put_flash(:success, "You now have access to #{membership.site.name}")
        |> redirect(external: "/sites/#{membership.site.id}")

      {:error, :invitation_not_found} ->
        conn
        |> put_flash(:error, "Invitation missing or already accepted")
        |> redirect(to: "/sites")

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong, please try again")
        |> redirect(to: "/sites")
    end
  end
end
