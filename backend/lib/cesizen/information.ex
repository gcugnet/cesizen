defmodule Cesizen.Information do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  alias Cesizen.Information.Content
  alias Cesizen.Information.Category

  resources do
    resource Category do
      define :list_categories, action: :read
      define :create_category, action: :create
      define :update_category, action: :update
      define :delete_category, action: :destroy
    end

    resource Content do
      define :list, action: :list
      define :create, action: :create
      define :update, action: :update
      define :delete, action: :destroy
    end
  end
end
