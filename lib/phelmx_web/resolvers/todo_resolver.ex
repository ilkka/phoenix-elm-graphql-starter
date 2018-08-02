defmodule PhelmxWeb.TodoResolver do
  alias Phelmx.Todo

  def all_tasks(_root, _args, _info) do
    tasks = Todo.list_tasks()
    {:ok, tasks}
  end
end
