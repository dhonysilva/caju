# mix phx.gen.schema Membership.Invitation invitations \
# email:string site_id:references:sites inviter_id:references:users \
# role:string invitation_id
defmodule Caju.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :role, :organization_membership_role, null: false
      add :invitation_id, :string
      add :site_id, references(:sites, on_delete: :delete_all, type: :binary_id)
      add :inviter_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:invitations, [:site_id])
    create index(:invitations, [:inviter_id])
  end
end
