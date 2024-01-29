defmodule CajuWeb.SiteLive do
  use CajuWeb, :live_view

  alias Caju.Repo
  alias Caju.Accounts

  def mount(params, %{"current_user_id" => user_id}, socket) do
    socket =
      socket
      |> assign(:filter_text, params["filter_text"] || "")
      |> assign(:user, Repo.get!(Caju.Accounts.User, user_id))

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:params, params)
      |> load_sites()
      |> assign_new(:has_sites?, fn %{user: user} ->
        Caju.Site.Memberships.any_or_pending?(user)
      end)
      |> assign_new(:has_sites?, fn %{user: user, sites: sites} ->
        user_owns_sites =
          Enum.any?(sites.entries, fn site ->
            List.first(site.memberships ++ site.invitations).role == :owner
          end) ||
            Accounts.user_owns_sites?(user)

        user_owns_sites
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Minhas tenants
      <:actions>
        <.link href={~p"/sites/new"}>
          <.button>+ Add Tenant</.button>
        </.link>
      </:actions>
    </.header>

    <.table id="sites" rows={@sites} row_click={&JS.navigate(~p"/sites/#{&1}")}>
      <:col :let={site} label="Name"><%= site.name %></:col>
      <:col :let={site} label="Invite">
        <.invitation
          :if={site.entry_type == "invitation"}
          site={site}
          invitation={hd(site.invitations)}
        />
      </:col>
      <:action :let={site}>
        <div class="sr-only">
          <.link navigate={~p"/sites/#{site}"}>Show</.link>
        </div>
        <.link navigate={~p"/sites/#{site}/edit"}>Edit</.link>
      </:action>
      <:action :let={site}>
        <.link href={~p"/sites/#{site}"} method="delete" data-confirm="Are you sure?">
          Delete
        </.link>
      </:action>
      <%!-- <:action :let={site}>
        <.link
          href={~p"/sites/invitations/#{site.invitation.invitation_id}/accept"}
          method="post"
          data-confirm="Are you sure?"
        >
          Convite
        </.link>
      </:action> --%>
    </.table>
    <%!-- <.flash_messages flash={@flash} /> --%>
    <%!-- <div
      x-data={"{selectedInvitation: null, invitationOpen: false, invitations: #{Enum.map(@invitations, &({&1.invitation.invitation_id, &1})) |> Enum.into(%{}) |> Jason.encode!}}"}
      x-on:keydown.escape.window="invitationOpen = false"
      class="container pt-6"
    > --%>
    <div class="container pt-6">
      <%!-- <PlausibleWeb.Live.Components.Visitors.gradient_defs /> --%>
      <%!-- <.upgrade_nag_screen :if={@needs_to_upgrade == {:needs_to_upgrade, :no_active_subscription}} /> --%>

      <div class="mt-6 pb-5 border-b border-gray-200 dark:border-gray-500 flex items-center justify-between">
        <h2 class="text-2xl font-bold leading-7 text-gray-900 dark:text-gray-100 sm:text-3xl sm:leading-9 sm:truncate flex-shrink-0">
          Minhas tenants
        </h2>
      </div>

      <div class="border-t border-gray-200 pt-4 sm:flex sm:items-center sm:justify-between">
        <div class="mt-4 flex sm:ml-4 sm:mt-0">
          <a href="/sites/new" class="button">
            + Add Tenant
          </a>
        </div>
      </div>

      <div :if={@has_sites?}>
        <ul class="my-6 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <%= for site <- @sites.entries do %>
            <.site site={site} />
            <.invitation
              :if={site.entry_type == "invitation"}
              site={site}
              invitation={hd(site.invitations)}
            />
          <% end %>
        </ul>

        <%!-- Total of <span class="font-medium"><%= @sites.total_entries %></span>
        sites </.pagination> --%>
        <%!-- <.invitation_modal
          :if={Enum.any?(@sites.entries, &(&1.entry_type == "invitation"))}
          user={@user}
        /> --%>
      </div>
    </div>
    """
  end

  attr :site, Caju.Membership.Site, required: true
  attr :invitation, Caju.Membership.Invitation, required: true

  def invitation(assigns) do
    ~H"""
    <li
      class="group cursor-pointer"
      id={"site-card-#{@site.id}"}
      data-domain={@site.id}
      x-on:click={"invitationOpen = true; selectedInvitation = invitations['#{@invitation.invitation_id}']"}
    >
      <div class="w-full flex items-center justify-between space-x-4">
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
          <.link
            href={~p"/sites/invitations/#{@invitation.invitation_id}/accept"}
            method="post"
            data-confirm="Are you sure?"
          >
            Convite
          </.link>
        </span>
        <.link
          href={~p"/sites/invitations/#{@invitation.invitation_id}/accept"}
          method="post"
          data-confirm="Are you sure?"
        >
          Convite
        </.link>
      </div>
    </li>
    """
  end

  attr :site, Caju.Membership.Site, required: true

  def site(assigns) do
    ~H"""
    <li
      class="group relative hidden"
      id={"site-card-#{@site.id}"}
      data-domain={@site.name}
      data-pin-toggled={
        JS.show(
          transition: {"duration-500", "opacity-0 shadow-2xl -translate-y-6", "opacity-100 shadow"},
          time: 400
        )
      }
      data-pin-failed={
        JS.show(
          transition: {"duration-500", "opacity-0", "opacity-100"},
          time: 200
        )
      }
      phx-mounted={JS.show()}
    >
      <a href={"/sites/#{@site.id}"}>
        <div class="col-span-1 bg-white dark:bg-gray-800 rounded-lg shadow p-4 group-hover:shadow-lg cursor-pointer">
          <div class="w-full flex items-center justify-between space-x-4">
            <div class="flex-1 -mt-px w-full">
              <h3
                class="text-gray-900 font-medium text-lg truncate dark:text-gray-100"
                style="width: calc(100% - 4rem)"
              >
                <%= @site.name %>
              </h3>
            </div>
          </div>
        </div>
      </a>
    </li>
    """
  end

  defp load_sites(%{assigns: assigns} = socket) do
    sites =
      Caju.Membership.list_with_invitations(assigns.user, assigns.params,
        filter_by_domain: assigns.filter_text
      )

    invitations = extract_invitations(sites.entries, assigns.user)

    assign(
      socket,
      sites: sites,
      invitations: invitations
    )
  end

  defp extract_invitations(sites, _user) do
    sites
    |> Enum.filter(&(&1.entry_type == "invitation"))
    |> Enum.flat_map(& &1.invitations)
  end
end
