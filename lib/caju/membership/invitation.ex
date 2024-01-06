defmodule Caju.Membership.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :role, :string
    field :email, :string
    field :invitation_id, :string
    field :site_id, :binary_id
    field :inviter_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :role, :invitation_id])
    |> validate_required([:email, :role, :invitation_id])
  end
end
