alias Cesizen.Users.User

defmodule Cesizen.Users do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

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
        get :read
        index :read
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  resources do
    resource User do
      define :create, action: :create
      define :list, action: :read
      define :update, action: :update
      define :delete, action: :destroy
    end

    resource Cesizen.Users.Token
    resource Cesizen.Users.UserEmotion
  end
end
