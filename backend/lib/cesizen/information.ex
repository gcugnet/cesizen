defmodule Cesizen.Information do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  resources do
    resource Cesizen.Information.Category
  end
end
