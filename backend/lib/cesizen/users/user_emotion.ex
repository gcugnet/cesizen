defmodule Cesizen.Users.UserEmotion do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Users,
    data_layer: AshPostgres.DataLayer

  alias Cesizen.Emotions.Emotion
  alias Cesizen.Users.User

  require Ash.Query
  postgres do
    table "user_emotions"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, User, allow_nil?: false
    belongs_to :emotion, Emotion, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :list_user_emotions do
      description "Retrieve entries in user_emotions for the current actor."

      prepare fn query, %{actor: actor} = context ->
        query
        |> Ash.Query.filter(user_id == ^actor.id)
      end
    end

    read :get_user_emotion do
      description "Get one entry in user_emotions corresponding to the given uuid."

      get_by :id

      prepare fn query, _context ->
        query
        |> Ash.Query.load(:emotion)
      end
    end

    create :add_user_emotion do
      description "Adds a new entry to user_emotions for the current actor."

      change relate_actor(:user)

      argument :emotion, :uuid do
        allow_nil? false
      end

      change manage_relationship(:emotion, type: :append)
    end
  end
end
