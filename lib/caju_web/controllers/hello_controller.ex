defmodule CajuWeb.HelloController do
  use CajuWeb, :controller

  # Here on this action, we don't have params
  def index(conn, _params) do
    conn
    |> put_layout(html: :admin)
    |> render(:index)
  end

  # Here, this action is receiving a param which is the name of the messenger.
  # We need to extract the the messenger from the parameters
  def show(conn, %{"messenger" => messenger}) do
    render(conn, :show, messenger: messenger)
  end

  # Within the body of the show action, we also pass a third argument to the render function, a key-value pair
  # where :messenger variable is passed as the value.

  # If the body of the action needs access to the full map of parameters bound to the params variable,
  # in addition to the bound messenger variable, we could define show/2 like this:

  # def show(conn, %{"messenger" => messenger} = params) do
  #   ...
  # end

  # It's good to remember that the keys of the params map will always be strings, and
  # the equals sign does not represent assignment, but instead a pattern mathinc assertion.
end
