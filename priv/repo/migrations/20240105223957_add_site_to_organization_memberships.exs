# mix ecto.gen.migration add_site_to_organization_memberships
defmodule Caju.Repo.Migrations.AddSiteToOrganizationMemberships do
  use Ecto.Migration

  def change do
    alter table(:organization_memberships) do
      add :site_id, references(:sites, type: :binary_id)
    end
  end
end
