defmodule Cesizen.Accounts.User do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Accounts,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "user"

    routes do
      base "/users"

      get :read
      index :read
      post :create
      patch :update
      delete :destroy
    end
  end

  postgres do
    table "users"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :name, :ci_string, allow_nil?: false, public?: true

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:user, :admin]
      default :user
      public? true
    end

    timestamps()
  end

  identities do
    identity :email, [:email]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
