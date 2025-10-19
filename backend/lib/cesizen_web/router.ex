defmodule CesizenWeb.Router do
  use CesizenWeb, :router

  import AshAuthentication.Plug.Helpers

  alias CesizenWeb.GitHubController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CesizenWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :retrieve_from_bearer, :cesizen
    plug :set_actor, :user
  end

  scope "/api/v1" do
    pipe_through [:api]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/v1/open_api",
      default_model_expand_depth: 4

    post "/issues", GitHubController, :create_issue

    forward "/", CesizenWeb.AshJsonApiRouter
  end

  scope "/", CesizenWeb do
    pipe_through :browser

    get "/", PageController, :home

    # ------------------------------------------------------------------------ #
    #                                 Users                                    #
    # ------------------------------------------------------------------------ #
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    # ------------------------------------------------------------------------ #
    #                          Information Categories                          #
    # ------------------------------------------------------------------------ #
    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Index, :new
    live "/categories/:id/edit", CategoryLive.Index, :edit

    live "/categories/:id", CategoryLive.Show, :show
    live "/categories/:id/show/edit", CategoryLive.Show, :edit

    # ------------------------------------------------------------------------ #
    #                           Information Contents                           #
    # ------------------------------------------------------------------------ #

    live "/contents", ContentLive.Index, :index
    live "/contents/new", ContentLive.Index, :new
    live "/contents/:id/edit", ContentLive.Index, :edit

    live "/contents/:id", ContentLive.Show, :show
    live "/contents/:id/show/edit", ContentLive.Show, :edit

    # ------------------------------------------------------------------------ #
    #                             Basic Emotions                               #
    # ------------------------------------------------------------------------ #
    live "/basic_emotions", BasicEmotionLive.Index, :index
    live "/basic_emotions/new", BasicEmotionLive.Index, :new
    live "/basic_emotions/:id/edit", BasicEmotionLive.Index, :edit

    live "/basic_emotions/:id", BasicEmotionLive.Show, :show
    live "/basic_emotions/:id/show/edit", BasicEmotionLive.Show, :edit

    # ------------------------------------------------------------------------ #
    #                                Emotions                                  #
    # ------------------------------------------------------------------------ #
    live "/emotions", EmotionLive.Index, :index
    live "/emotions/new", EmotionLive.Index, :new
    live "/emotions/:id/edit", EmotionLive.Index, :edit

    live "/emotions/:id", EmotionLive.Show, :show
    live "/emotions/:id/show/edit", EmotionLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", CesizenWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cesizen, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CesizenWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
