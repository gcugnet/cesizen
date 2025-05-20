defmodule Cesizen.Emotions.BasicEmotion do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Emotions,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "basic_emotion"
  end

  postgres do
    table "basic_emotions"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :ci_string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  identities do
    identity :unique_name, [:name]
  end

  actions do
    defaults [:read, :destroy, create: [:name], update: [:name]]
  end
end
