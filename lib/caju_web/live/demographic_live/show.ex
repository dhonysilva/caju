defmodule CajuWeb.DemographicLive.Show do
  use Phoenix.Component
  use Phoenix.HTML

  alias Caju.Survey.Demographic
  alias CajuWeb.CoreComponents

  attr :demographic, Demographic, required: true

  def details(assigns) do
    ~H"""
    <div>
      <h2 class="font-medium text-2xl">
        Demographics <%= raw("&#x2713;") %>
      </h2>

      <CoreComponents.table rows={[@demographic]} id={to_string(@demographic.id)}>
        <:col :let={demographic} label="Gender"><%= demographic.gender %></:col>
        <:col :let={demographic} label="Year of Birth"><%= demographic.year_of_birth %></:col>
        <:col :let={demographic} label="Cadastrado"><%= demographic.inserted_at %></:col>
      </CoreComponents.table>
    </div>
    """
  end
end
