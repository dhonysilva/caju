defmodule Caju.Membership.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @required [:email, :role, :site_id, :inviter_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :role, Ecto.Enum, values: [:owner, :admin, :viewer]
    field :email, :string
    field :invitation_id, :string

    belongs_to :site, Caju.Membership.Site
    belongs_to :inviter, Caju.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :role, :invitation_id])
    |> validate_required([:email, :role, :invitation_id])
  end

  def new(attrs \\ %{}) do
    %__MODULE__{invitation_id: Nanoid.generate()}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> unique_constraint([:email, :site_id],
      name: :invitations_site_id_email_index,
      error_key: :invitation,
      message: "already sent"
    )
  end
end
