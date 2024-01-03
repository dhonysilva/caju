# mix phx.gen.context Orders LineItem order_line_items \
# price:decimal quantity:integer order_id:references:orders product_id:references:products

defmodule Caju.Repo.Migrations.CreateOrderLineItems do
  use Ecto.Migration

  def change do
    create table(:order_line_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :price, :decimal, precision: 15, scale: 6, null: false
      add :quantity, :integer
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
      add :product_id, references(:products, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:order_line_items, [:order_id])
    create index(:order_line_items, [:product_id])
  end
end
