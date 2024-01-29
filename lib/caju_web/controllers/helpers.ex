defmodule CajuWeb.ControllerHelpers do
  import Plug.Conn
  import Phoenix.Controller

  def render_error(conn, status, message) do
    conn
    |> put_status(status)
    |> put_view(CajuWeb.ErrorView)
    |> render("#{status}.html", message: message, layout: error_layout())
  end

  def render_error(conn, status) do
    conn
    |> put_status(status)
    |> put_view(CajuWeb.ErrorView)
    |> render("#{status}.html", layout: error_layout())
  end

  defp error_layout,
    do: Application.get_env(:plausible, CajuWeb.Endpoint)[:render_errors][:layout]
end
