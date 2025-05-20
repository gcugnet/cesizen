defmodule Cesizen.Information do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  alias Cesizen.Information.Content
  alias Cesizen.Information.Category

  json_api do
    routes do
      base_route "/information/categories", Category do
        index :read
        get :get
        post :create
        patch :update
        delete :destroy
      end

      base_route "/information/contents", Content do
        index :list
        get :get
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  resources do
    resource Category do
      define :list_categories, action: :read
      define :get_category, action: :get
      define :create_category, action: :create
      define :update_category, action: :update
      define :delete_category, action: :destroy
    end

    resource Content do
      define :list, action: :list
      define :get, action: :get
      define :create, action: :create
      define :update, action: :update
      define :delete, action: :destroy
    end
  end
end
