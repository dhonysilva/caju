defmodule CajuWeb.SurveyLive.Component do
  use Phoenix.Component

  attr :content, :string, required: true
  slot :inner_block, required: true

  def hero(assigns) do
    ~H"""
    <h1 class="font-heavy text-3xl">
      <%= @content %>
    </h1>

    <h3>
      <%= render_slot(@inner_block) %>
    </h3>

    <pre>
    <%= inspect(assigns, pretty: true) %>
    <% %{ inner_block: [%{inner_block: block_fn}]} = assigns %>
    <%= inspect(block_fn.(assigns.__changed__, assigns), pretty: true) %>
    </pre>
    """
  end
end
