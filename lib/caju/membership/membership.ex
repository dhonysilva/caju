defmodule Caju.Membership.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @roles [:owner, :admin, :viewer]

  @type t() :: %__MODULE__{}

  # Generate a union type for roles
  @type role() :: unquote(Enum.reduce(@roles, &{:|, [], [&1, &2]}))

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "org_memberships" do
    field :role, Ecto.Enum, values: @roles
    belongs_to :user, Caju.Accounts.User
    belongs_to :org, Caju.Membership.Organization

    timestamps()
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end

  def new(account, user) do
    %__MODULE__{}
    |> change()
    |> put_assoc(:account, account)
    |> put_assoc(:user, user)
  end

  def set_role(changeset, role) do
    changeset
    |> cast(%{role: role}, [:role])
  end
end
