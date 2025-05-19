defmodule Cesizen.Emotions.Emotion do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Emotions,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "emotion"
  end

  postgres do
    table "emotions"
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

  relationships do
    belongs_to :basic_emotion, Cesizen.Emotions.BasicEmotion
  end

  actions do
    defaults [:read, :destroy, create: [:name], update: [:name]]
  end
end
