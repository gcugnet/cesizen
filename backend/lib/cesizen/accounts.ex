alias Cesizen.Accounts.User

defmodule Cesizen.Accounts do
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
      define :create_user, action: :create
      define :list_users, action: :read
      define :update_user, action: :update
      define :delete_user, action: :destroy
    end

    resource Cesizen.Accounts.Token
  end
end
