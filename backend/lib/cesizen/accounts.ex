alias Cesizen.Accounts.User

defmodule Cesizen.Accounts do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

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
