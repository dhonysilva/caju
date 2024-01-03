defmodule Caju.Orders.LineItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_line_items" do
    field :price, :decimal
    field :quantity, :integer
    # field :order_id, :binary_id
    # field :product_id, :binary_id

    belongs_to :order, Caju.Orders.Order
    belongs_to :product, Caju.Catalog.Product

    timestamps()
  end

  @doc false
  def changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:price, :quantity])
    |> validate_required([:price, :quantity])
  end
end
