defmodule CajuWeb.SiteController do
  use CajuWeb, :controller

  alias Caju.Membership
  alias Caju.Membership.Site

  def index(conn, _params) do
    sites = Membership.list_sites()
    render(conn, :index, sites: sites)
  end

  def new(conn, _params) do
    changeset = Membership.change_site(%Site{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"site" => site_params}) do
    case Membership.create_site(site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site created successfully.")
        |> redirect(to: ~p"/sites/#{site}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    render(conn, :show, site: site)
  end

  def edit(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    changeset = Membership.change_site(site)
    render(conn, :edit, site: site, changeset: changeset)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = Membership.get_site!(id)

    case Membership.update_site(site, site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site updated successfully.")
        |> redirect(to: ~p"/sites/#{site}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, site: site, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = Membership.get_site!(id)
    {:ok, _site} = Membership.delete_site(site)

    conn
    |> put_flash(:info, "Site deleted successfully.")
    |> redirect(to: ~p"/sites")
  end
end
