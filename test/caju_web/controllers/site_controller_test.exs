defmodule CajuWeb.SiteControllerTest do
  use CajuWeb.ConnCase

  import Caju.MembershipFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all sites", %{conn: conn} do
      conn = get(conn, ~p"/sites")
      assert html_response(conn, 200) =~ "Listing Sites"
    end
  end

  describe "new site" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/sites/new")
      assert html_response(conn, 200) =~ "New Site"
    end
  end

  describe "create site" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/sites", site: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/sites/#{id}"

      conn = get(conn, ~p"/sites/#{id}")
      assert html_response(conn, 200) =~ "Site #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/sites", site: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Site"
    end
  end

  describe "edit site" do
    setup [:create_site]

    test "renders form for editing chosen site", %{conn: conn, site: site} do
      conn = get(conn, ~p"/sites/#{site}/edit")
      assert html_response(conn, 200) =~ "Edit Site"
    end
  end

  describe "update site" do
    setup [:create_site]

    test "redirects when data is valid", %{conn: conn, site: site} do
      conn = put(conn, ~p"/sites/#{site}", site: @update_attrs)
      assert redirected_to(conn) == ~p"/sites/#{site}"

      conn = get(conn, ~p"/sites/#{site}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn = put(conn, ~p"/sites/#{site}", site: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Site"
    end
  end

  describe "delete site" do
    setup [:create_site]

    test "deletes chosen site", %{conn: conn, site: site} do
      conn = delete(conn, ~p"/sites/#{site}")
      assert redirected_to(conn) == ~p"/sites"

      assert_error_sent 404, fn ->
        get(conn, ~p"/sites/#{site}")
      end
    end
  end

  defp create_site(_) do
    site = site_fixture()
    %{site: site}
  end
end
