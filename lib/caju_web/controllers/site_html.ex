defmodule CajuWeb.SiteHTML do
  use CajuWeb, :html

  embed_templates "site_html/*"

  @doc """
  Renders a site form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def site_form(assigns)
end
