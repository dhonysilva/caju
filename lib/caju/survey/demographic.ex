defmodule Caju.Survey.Demographic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "demographics" do
    field :gender, :string
    field :year_of_birth, :integer

    belongs_to :user, Caju.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(demographic, attrs) do
    demographic
    |> cast(attrs, [:gender, :year_of_birth, :user_id])
    |> validate_required([:gender, :year_of_birth, :user_id])
    |> validate_inclusion(:gender, ["male", "female", "other", "prefer not to say"])
    |> validate_inclusion(:year_of_birth, 1900..2024)
    |> unique_constraint(:user_id)
  end
end
