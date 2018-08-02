# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Phelmx.Repo.insert!(%Phelmx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Phelmx.Todo.Task
alias Phelmx.Repo

%Task{description: "Learn how to wire Phoenix and Elm up", done: false}
  |> Repo.insert!

%Task{description: "Get an air conditioner for the apartment", done: false}
  |> Repo.insert!

