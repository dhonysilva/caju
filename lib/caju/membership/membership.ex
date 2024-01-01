defmodule Caju.Membership.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @roles [:owner, :admin, :viewer]

  @type t() :: %__MODULE__{}

  # Generate a union type for roles
  @type role() :: unquote(Enum.reduce(@roles, &{:|, [], [&1, &2]}))

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "organization_memberships" do
    field :role, Ecto.Enum, values: @roles

    belongs_to :user, Caju.Accounts.User
    belongs_to :organization, Caju.Membership.Organization

    timestamps()
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :user_id, :organization_id])
    |> validate_required([:role, :user_id, :organization_id])
  end

  def new(organization, user) do
    %__MODULE__{}
    |> change()
    |> put_assoc(:organization, organization)
    |> put_assoc(:user, user)
  end

  def set_role(changeset, role) do
    changeset
    |> cast(%{role: role}, [:role])
  end
end
