defmodule PhelmxWeb.Router do
  use PhelmxWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :graphql do
    # plug(:accepts, ["json"])
  end

  # graphql API scope
  scope "/" do
    pipe_through(:graphql)
    forward("/graphql", Absinthe.Plug, schema: PhelmxWeb.Schema)
  end

  # browser scope
  scope "/", PhelmxWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # graphiql scope
  scope "/" do
    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: PhelmxWeb.Schema,
      socket: PhelmxWeb.UserSocket,
      default_url: "/graphql"
    )
  end
end
