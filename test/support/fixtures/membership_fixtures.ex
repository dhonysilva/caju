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
end
