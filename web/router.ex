defmodule ActiveMonitoring.Router do
  use ActiveMonitoring.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, db_model: ActiveMonitoring.User
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, db_model: ActiveMonitoring.User, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash

    plug Coherence.Authentication.Session, db_model: ActiveMonitoring.User, protected: true
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through [:browser]
      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end

  scope "/api", ActiveMonitoring do
    pipe_through :api

    scope "/v1" do
      delete "/sessions", SessionController, :api_delete

      resources "/campaigns", CampaignsController, only: [:index, :create, :update, :delete]
    end
  end

  scope "/", ActiveMonitoring do
    pipe_through :browser
    coherence_routes :public

    get "/login", SessionController, :login
    get "/logout", SessionController, :delete

    get "/oauth_callback", SessionController, :oauth_callback

    get "/*path", PageController, :index
  end
end
