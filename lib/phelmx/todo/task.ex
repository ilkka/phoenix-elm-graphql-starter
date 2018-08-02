defmodule Phelmx.Todo.Task do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tasks" do
    field :description, :string
    field :done, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:description, :done])
    |> validate_required([:description, :done])
  end
end
