defmodule Caju.Membership.Site do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sites" do
    field :name, :string

    many_to_many :members, Caju.Accounts.User, join_through: Caju.Membership.Membership
    has_many :memberships, Caju.Membership.Membership
    has_many :invitations, Caju.Membership.Invitation
    has_one :ownership, Caju.Membership.Membership, where: [role: :owner]
    has_one :owner, through: [:ownership, :user]

    # Used in the context of paginated sites list to order in relation to
    # user's membership state. Currently it can be either "invitation",
    # "pinned_site" or "site", where invitations are first.
    field :entry_type, :string, virtual: true

    timestamps()
  end

  def new(params), do: changeset(%__MODULE__{}, params)

  @doc false
  def changeset(site, attrs \\ %{}) do
    site
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
