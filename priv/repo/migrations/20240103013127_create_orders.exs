# mix phx.gen.context Orders Order orders user_uuid:uuid total_price:decimal

defmodule Caju.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_uuid, :uuid
      add :total_price, :decimal, precision: 15, scale: 6, null: false

      timestamps()
    end
  end
end
