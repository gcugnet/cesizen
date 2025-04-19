defmodule Cesizen.Repo do
  use Ecto.Repo,
    otp_app: :cesizen,
    adapter: Ecto.Adapters.Postgres
end
