# mix ecto.gen.migration add_role_to_organization_memberships
defmodule Caju.Repo.Migrations.AddRoleToOrganizationMemberships do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE organization_membership_role AS ENUM ('owner', 'admin', 'viewer')"
    drop_query = "DROP TYPE organization_membership_role"
    execute(create_query, drop_query)

    alter table(:organization_memberships) do
      add :role, :organization_membership_role, null: false, default: "owner"
    end
  end
end
