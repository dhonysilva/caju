defmodule Caju.MembershipTest do
  use Caju.DataCase

  alias Caju.Membership

  describe "orgs" do
    alias Caju.Membership.Organization

    import Caju.MembershipFixtures

    @invalid_attrs %{name: nil}

    test "list_orgs/0 returns all orgs" do
      organization = organization_fixture()
      assert Membership.list_orgs() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Membership.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Organization{} = organization} = Membership.create_organization(valid_attrs)
      assert organization.name == "some name"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Membership.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} = Membership.update_organization(organization, update_attrs)
      assert organization.name == "some updated name"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Membership.update_organization(organization, @invalid_attrs)
      assert organization == Membership.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Membership.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Membership.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Membership.change_organization(organization)
    end
  end

  describe "organizations" do
    alias Caju.Membership.Organization

    import Caju.MembershipFixtures

    @invalid_attrs %{name: nil}

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Membership.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Membership.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Organization{} = organization} = Membership.create_organization(valid_attrs)
      assert organization.name == "some name"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Membership.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} = Membership.update_organization(organization, update_attrs)
      assert organization.name == "some updated name"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Membership.update_organization(organization, @invalid_attrs)
      assert organization == Membership.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Membership.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Membership.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Membership.change_organization(organization)
    end
  end

  describe "sites" do
    alias Caju.Membership.Site

    import Caju.MembershipFixtures

    @invalid_attrs %{name: nil}

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert Membership.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Membership.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Site{} = site} = Membership.create_site(valid_attrs)
      assert site.name == "some name"
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Membership.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Site{} = site} = Membership.update_site(site, update_attrs)
      assert site.name == "some updated name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Membership.update_site(site, @invalid_attrs)
      assert site == Membership.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Membership.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Membership.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Membership.change_site(site)
    end
  end
end
