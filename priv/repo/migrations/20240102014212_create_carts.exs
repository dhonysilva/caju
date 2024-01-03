defmodule Caju.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_uuid, :uuid

      timestamps()
    end

    create unique_index(:carts, [:user_uuid])
  end
end
