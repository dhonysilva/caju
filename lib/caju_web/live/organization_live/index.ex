defmodule CajuWeb.OrganizationLive.Index do
  use CajuWeb, :live_view

  alias Caju.Membership
  alias Caju.Membership.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :organizations, Membership.list_organizations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, Membership.get_organization!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, %Organization{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_info({CajuWeb.OrganizationLive.FormComponent, {:saved, organization}}, socket) do
    {:noreply, stream_insert(socket, :organizations, organization)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization = Membership.get_organization!(id)
    {:ok, _} = Membership.delete_organization(organization)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end
end
