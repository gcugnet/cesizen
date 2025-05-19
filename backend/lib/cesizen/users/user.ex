defmodule Cesizen.Users.User do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Users,
    extensions: [AshAuthentication, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  alias Cesizen.Users.UserEmotion
  alias Cesizen.Emotions.Emotion

  json_api do
    type "user"
  end

  postgres do
    table "users"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false

      constraints max_length: 254,
                  match: ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/

      public? true
    end

    attribute :name, :ci_string do
      allow_nil? false
      constraints min_length: 3, max_length: 30
      public? true
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:user, :admin]
      default :user
      public? true
    end

    timestamps()

    attribute :hashed_password, :string do
      allow_nil? false
      constraints max_length: 128
      sensitive? true
    end

    attribute :confirmed_at, :utc_datetime_usec
  end

  relationships do
    many_to_many :emotions, Emotion do
      through UserEmotion
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :emotion_id
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  code_interface do
    define :login, action: :sign_in_with_password
  end

  actions do
    defaults [:read, :destroy, update: :*]

    read :get do
      get_by :id
    end

    create :create do
      description "Creates a new user and validates it.
        For admin convenience only."

      argument :name, :ci_string do
        allow_nil? false
      end

      argument :email, :ci_string do
        allow_nil? false
      end

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :role, :atom

      change set_context(%{strategy_name: :password})
      change set_attribute(:name, arg(:name))
      change set_attribute(:email, arg(:email))
      change set_attribute(:role, arg(:role))

      change AshAuthentication.Strategy.Password.HashPasswordChange
      change AshAuthentication.GenerateTokenChange

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    update :change_password do
      # Use this action to allow users to change their password by providing
      # their current password and a new password.

      require_atomic? false
      accept []
      argument :current_password, :string, sensitive?: true, allow_nil?: false

      argument :password, :string,
        sensitive?: true,
        allow_nil?: false,
        constraints: [min_length: 8]

      argument :password_confirmation, :string,
        sensitive?: true,
        allow_nil?: false

      validate confirm(:password, :password_confirmation)

      validate {AshAuthentication.Strategy.Password.PasswordValidation,
                strategy_name: :password, password_argument: :current_password}

      change {AshAuthentication.Strategy.Password.HashPasswordChange,
              strategy_name: :password}
    end

    read :sign_in_with_password do
      description "Attempt to sign in using a email and password."
      get? true

      argument :email, :ci_string do
        description "The email to use for retrieving the user."
        allow_nil? false
      end

      argument :password, :string do
        description "The password to check for the matching user."
        allow_nil? false
        sensitive? true
      end

      # validates the provided email and password and generates a token
      prepare AshAuthentication.Strategy.Password.SignInPreparation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    read :sign_in_with_token do
      # In the generated sign in components, we validate the
      # email and password directly in the LiveView
      # and generate a short-lived token that can be used to sign in over
      # a standard controller action, exchanging it for a standard token.
      # This action performs that exchange. If you do not use the generated
      # liveviews, you may remove this action, and set
      # `sign_in_tokens_enabled? false` in the password strategy.

      description "Attempt to sign in using a short-lived sign in token."
      get? true

      argument :token, :string do
        description "The short-lived sign in token."
        allow_nil? false
        sensitive? true
      end

      # validates the provided sign in token and generates a token
      prepare AshAuthentication.Strategy.Password.SignInWithTokenPreparation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    create :register_with_password do
      description "Register a new user with a email and password."

      argument :name, :ci_string do
        description "The user name."
        allow_nil? false
      end

      argument :email, :ci_string do
        allow_nil? false
      end

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        description "The proposed password for the user (again), in plain text."
        allow_nil? false
        sensitive? true
      end

      # Sets the name from the argument
      change set_attribute(:name, arg(:name))

      # Sets the email from the argument
      change set_attribute(:email, arg(:email))

      # Hashes the provided password
      change AshAuthentication.Strategy.Password.HashPasswordChange

      # Generates an authentication token for the user
      change AshAuthentication.GenerateTokenChange

      # validates that the password matches the confirmation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    action :request_password_reset_token do
      description "Send password reset instructions to a user if they exist."

      argument :email, :ci_string do
        allow_nil? false
      end

      # creates a reset token and invokes the relevant senders
      run {AshAuthentication.Strategy.Password.RequestPasswordReset,
           action: :get_by_email}
    end

    read :get_by_email do
      description "Looks up a user by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    update :reset_password_with_token do
      argument :reset_token, :string do
        allow_nil? false
        sensitive? true
      end

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        description "The proposed password for the user (again), in plain text."
        allow_nil? false
        sensitive? true
      end

      # validates the provided reset token
      validate AshAuthentication.Strategy.Password.ResetTokenValidation

      # validates that the password matches the confirmation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      # Hashes the provided password
      change AshAuthentication.Strategy.Password.HashPasswordChange

      # Generates an authentication token for the user
      change AshAuthentication.GenerateTokenChange
    end
  end

  authentication do
    tokens do
      enabled? true
      token_resource Cesizen.Users.Token
      store_all_tokens? true
      require_token_presence_for_authentication? true

      signing_secret fn _, _ ->
        Application.fetch_env(:cesizen, :token_signing_secret)
      end

      add_ons do
        log_out_everywhere do
          apply_on_password_change? true
        end
      end
    end

    strategies do
      password :password do
        identity_field :email
        # sign_in_tokens_enabled? true

        resettable do
          sender Cesizen.Users.User.Senders.SendPasswordResetEmail
          # these configurations will be the default in a future release
          password_reset_action_name :reset_password_with_token
          request_password_reset_action_name :request_password_reset_token
        end
      end
    end

    add_ons do
      confirmation :confirm_new_user do
        monitor_fields [:email]
        confirm_on_create? true
        confirm_on_update? false
        require_interaction? true
        confirmed_at_field :confirmed_at

        auto_confirm_actions [
          :create,
          :register_with_password,
          :sign_in_with_magic_link,
          :reset_password_with_token
        ]

        sender Cesizen.Users.User.Senders.SendNewUserConfirmationEmail
      end
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action([
             :sign_in_with_password,
             :register_with_password,
             :get
           ]) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:seeder, true)
    end
  end
end
