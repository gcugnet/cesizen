defmodule Cesizen.Emotions do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  alias Cesizen.Emotions.Emotion
  alias Cesizen.Emotions.BasicEmotion

  resources do
    resource BasicEmotion do
      define :list_basic, action: :read
      define :create_basic, action: :create
      define :update_basic, action: :update
      define :delete_basic, action: :destroy
    end

    resource Emotion do
      define :list, action: :list
      define :create, action: :create
      define :update, action: :update
      define :delete, action: :destroy
    end
  end
end
