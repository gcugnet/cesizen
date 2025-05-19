defmodule Cesizen.Emotions do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  alias Cesizen.Emotions.Emotion
  alias Cesizen.Emotions.BasicEmotion

  json_api do
    routes do
      base_route "/basic-emotions", BasicEmotion do
        index :read
        post :create
        patch :update
        delete :destroy
      end

      base_route "/emotions", Emotion do
        index :read
        post :create
        patch :update
        delete :destroy
      end
    end
  end

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
