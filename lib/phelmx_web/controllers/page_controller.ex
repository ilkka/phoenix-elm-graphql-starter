defmodule PhelmxWeb.PageController do
  use PhelmxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
