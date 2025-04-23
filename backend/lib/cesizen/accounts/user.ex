defmodule Cesizen.Accounts.User do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Accounts,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "user"
  end

  postgres do
    table "users"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:user, :admin]
      default :user
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

end
