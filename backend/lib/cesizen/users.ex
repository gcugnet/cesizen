defmodule Cesizen.Users do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  alias Cesizen.Users.Token
  alias Cesizen.Users.User
  alias Cesizen.Users.UserEmotion

  json_api do
    routes do
      base_route "/", User do
        post :sign_in_with_password do
          route "/login"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end

        post :register_with_password do
          route "/register"
        end
      end

      base_route "/users", User do
        index :read
        get :get
        post :create
        patch :update
        delete :destroy
      end

      base_route "/users/emotions", UserEmotion do
        index :list_user_emotions
        get :get_user_emotion
        post :add_user_emotion
        delete :destroy
      end
    end
  end

  resources do
    resource User do
      define :list, action: :read
      define :get, action: :get
      define :create, action: :create
      define :update, action: :update
      define :delete, action: :destroy
    end

    resource UserEmotion do
      define :add_emotion, action: :add_user_emotion
      define :list_emotions, action: :list_user_emotions
      define :get_emotion, action: :get_user_emotion
      define :delete_emotion, action: :destroy
    end

    resource Token
  end
end
