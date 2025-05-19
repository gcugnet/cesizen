alias Cesizen.Emotions.Emotion
alias Cesizen.Users.User

defmodule Cesizen.Users.UserEmotion do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Users,
    data_layer: AshPostgres.DataLayer

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
  end
end
