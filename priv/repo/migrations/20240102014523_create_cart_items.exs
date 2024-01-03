defmodule Caju.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :price_when_carted, :decimal, precision: 15, scale: 6, null: false
      add :quantity, :integer
      add :cart_id, references(:carts, on_delete: :delete_all, type: :binary_id)
      add :product_id, references(:products, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:cart_items, [:cart_id, :product_id])
    create index(:cart_items, [:product_id])
  end
end
