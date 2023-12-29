defmodule Caju.Repo.Migrations.AddOrgToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :org_id, references(:orgs, on_delete: :nothing, type: :binary_id)
    end
  end
end
