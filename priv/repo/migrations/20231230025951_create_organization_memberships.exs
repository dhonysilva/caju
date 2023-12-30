defmodule Caju.Repo.Migrations.CreateOrganizationMemberships do
  use Ecto.Migration

  def change do
    create table(:organization_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:organization_memberships, [:user_id])
    create index(:organization_memberships, [:organization_id])
  end
end
