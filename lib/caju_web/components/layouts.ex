defmodule CajuWeb.Layouts do
  use CajuWeb, :html

  embed_templates "layouts/*"

  def home_dest(conn) do
    if conn.assigns[:current_user] do
      "/sites"
    else
      "/"
    end
  end
end
