defmodule Cesizen.Information.Category do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Information,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "category"
  end

  postgres do
    table "categories"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    timestamps()
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:name, :description],
      update: [:name, :description]
    ]
  end
end
