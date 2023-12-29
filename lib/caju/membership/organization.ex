defmodule Caju.Membership.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orgs" do
    field :name, :string

    many_to_many :members, Caju.Accounts.User, join_through: Caju.Membership.Membership
    has_many :memberships, Caju.Membership.Membership

    has_one :ownership, Caju.Membership.Membership
    has_one :onwer, through: [:ownership, :user]

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
