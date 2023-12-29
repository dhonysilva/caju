defmodule Caju.Repo do
  use Ecto.Repo,
    otp_app: :caju,
    adapter: Ecto.Adapters.Postgres
end
