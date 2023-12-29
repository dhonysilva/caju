defmodule Caju.Repo.Migrations.CreateOrgMemberships do
  use Ecto.Migration

  def change do
    create table(:org_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :org_id, references(:orgs, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:org_memberships, [:user_id, :org_id])
  end
end
