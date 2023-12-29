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
end
