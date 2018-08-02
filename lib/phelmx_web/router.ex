defmodule PhelmxWeb.Router do
  use PhelmxWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PhelmxWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/api", PhelmxWeb do
    pipe_through(:api)
  end

  scope "/api" do
    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: PhelmxWeb.Schema,
      interface: :simple,
      context: %{pubsub: PhelmxWeb.Endpoint}
    )
  end
end
