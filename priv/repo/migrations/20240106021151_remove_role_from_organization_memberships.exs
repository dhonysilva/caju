# mix ecto.gen.migration remove_role_from_organization_memberships
defmodule Caju.Repo.Migrations.RemoveRoleFromOrganizationMemberships do
  use Ecto.Migration

  def change do
    alter table(:organization_memberships) do
      remove :role
    end
  end
end
