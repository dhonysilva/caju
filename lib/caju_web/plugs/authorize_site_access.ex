defmodule CajuWeb.AuthorizeSiteAccess do
  import Plug.Conn
  use Caju.Repo

  def init([]), do: [:public, :viewer, :admin, :super_admin, :owner]
  def init(allowed_roles), do: allowed_roles

  def call(conn, allowed_roles) do
    site =
      Repo.get_by(
        Caju.Membership.Site,
        id:
          conn.path_params["website"] || conn.path_params["site"] ||
            conn.path_params["id"]
      )

    if !site do
      CajuWeb.ControllerHelpers.render_error(conn, 404) |> halt
    else
      user_id = get_session(conn, :current_user_id)
      membership_role = user_id && Caju.Membership.role(user_id, site)

      role =
        cond do
          user_id && membership_role ->
            membership_role

          Caju.Accounts.is_super_admin?(user_id) ->
            :super_admin

          true ->
            nil
        end

      if role in allowed_roles do
        Sentry.Context.set_user_context(%{id: user_id})
        Caju.OpenTelemetry.add_user_attributes(user_id)

        Sentry.Context.set_extra_context(%{site_id: site.id, name: site.name})
        Caju.OpenTelemetry.add_site_attributes(site)

        merge_assigns(conn, site: site, current_user_role: role)
      else
        CajuWeb.ControllerHelpers.render_error(conn, 404) |> halt
      end
    end
  end
end
