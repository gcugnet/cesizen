defmodule Cesizen.Emotions.Emotion do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Emotions,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  require Ash.Query

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
    belongs_to :basic_emotion, Cesizen.Emotions.BasicEmotion do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, update: [:name]]

    create :create do
      primary? true
      description "Creates a new Emotion."

      argument :basic_emotion, :uuid do
        allow_nil? false
      end

      argument :name, :ci_string do
        allow_nil? false
      end

      change manage_relationship(:basic_emotion, type: :append)
      change set_attribute(:name, arg(:name))
    end

    read :list do
      argument :basic_emotion, :uuid do
      end

      prepare fn query, _context ->
        case Ash.Query.fetch_argument(query, :basic_emotion) do
          {:ok, basic_emotion} ->
            query
            |> Ash.Query.filter(basic_emotion_id == ^basic_emotion)

          _ ->
            query
        end
      end
    end
  end
end
