defmodule CajuWeb.DemographicLive.Form do
  use CajuWeb, :live_component
  alias Caju.Survey
  alias Caju.Survey.Demographic

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> clear_form()
    }
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: current_user.id})
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp clear_form(%{assigns: %{demographic: demographic}} = socket) do
    assign_form(socket, Survey.change_demographic(demographic))
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    params = params_with_user_id(demographic_params, socket)
    {:noreply, save_demographic(socket, params)}
  end

  def params_with_user_id(params, %{assigns: %{current_user: current_user}}) do
    params
    |> Map.put("user_id", current_user.id)
  end

  defp save_demographic(socket, demographic_params) do
    case Survey.create_demographic(demographic_params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end
end
