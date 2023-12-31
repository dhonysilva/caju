defmodule Caju.MembershipFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Caju.Membership` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Caju.Membership.create_organization()

    organization
  end

  @doc """
  Generate a site.
  """
  def site_fixture(attrs \\ %{}) do
    {:ok, site} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Caju.Membership.create_site()

    site
  end
end
