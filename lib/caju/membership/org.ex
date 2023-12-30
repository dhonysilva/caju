defmodule Caju.Membership.Org do
  alias Caju.Membership
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @type t() :: %__MODULE__{}

  schema "orgs" do
    field :name, :string

    many_to_many :members, Caju.Accounts.User, join_through: Caju.Membership.Membership
    has_many :memberships, Caju.Membership.Membership

    has_one :ownership, Caju.Membership.Membership
    has_one :onwer, through: [:ownership, :user]

    timestamps()
  end

  def new(params), do: changeset(%__MODULE__{}, params)

  @doc false
  def changeset(organization, attrs \\ %{}) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:memberships, with: &Membership.Membership.changeset/2)
  end
end
