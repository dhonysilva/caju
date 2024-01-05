defmodule Caju.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias Caju.Catalog.Category

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :description, :string
    field :title, :string
    field :price, :decimal
    field :views, :integer

    many_to_many :categories, Category, join_through: "product_categories", on_replace: :delete

    has_many :ratings, Caju.Survey.Rating

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :views])
    |> validate_required([:title, :description, :price, :views])
  end
end
