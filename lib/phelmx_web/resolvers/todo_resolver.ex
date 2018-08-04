defmodule PhelmxWeb.TodoResolver do
  alias Phelmx.Todo

  def all_tasks(_root, _args, _info) do
    tasks = Todo.list_tasks()
    {:ok, tasks}
  end

  def create_task(_root, args, _info) do
    case Todo.create_task(args) do
      {:ok, task} ->
        {:ok, task}

      _ ->
        {:error, "could not create task"}
    end
  end

  def update_task(_root, args, _info) do
    task = Todo.get_task!(args.id)

    case(Todo.update_task(task, %{done: true})) do
      {:ok, task} ->
        {:ok, task}

      _ ->
        {:error, "could not update task"}
    end
  end
end
