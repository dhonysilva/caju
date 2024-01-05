# mix phx.gen.context Survey Rating ratings stars:integer user_id:references:users product_id:references:products

defmodule Caju.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :stars, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :product_id, references(:products, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:ratings, [:user_id])
    create index(:ratings, [:product_id])

    create unique_index(:ratings, [:user_id, :product_id], name: :index_ratings_on_user_product)
  end
end
