defmodule CajuWeb.HelloHTML do
  use CajuWeb, :html

  # Defining as a function component
  # def index(assigns) do
  #   ~H"""
  #   Hello! Estou sendo exibindo de dentro de uma Function Component.
  #   """
  # end

  # Defining calling all the templates files stored on hello_html folder.
  # For this exercise, we're going to create and use the index.html.heex template own file.

  # Here we are telling Phoenix.Component to embed all .heex templates found in the  sibling hello_html directory into our module as function definition.
  embed_templates "hello_html/*"

  attr :messenger, :string

  def greet(assigns) do
    ~H"""
    <p>
      Hello from <%= @messenger %>. Esse texto vem de dentro de um template file chamado show.html.heex
    </p>
    """
  end
end
