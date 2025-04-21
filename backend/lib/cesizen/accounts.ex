defmodule Cesizen.Accounts do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  resources do
    resource(Cesizen.Accounts.User)
  end
end
