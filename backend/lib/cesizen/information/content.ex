defmodule Cesizen.Information.Content do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Information,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "content"
  end

  postgres do
    table "contents"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:text, :image]
      default :text
      public? true
    end

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :category, Cesizen.Information.Category do
      public? true
    end
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: :*,
      update: :*
    ]
  end
end
