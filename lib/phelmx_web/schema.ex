defmodule PhelmxWeb.Schema do
  use Absinthe.Schema

  alias PhelmxWeb.TodoResolver

  object :task do
    field(:id, non_null(:id))
    field(:description, non_null(:string))
    field(:done, non_null(:boolean))
  end

  query do
    field(:all_tasks, non_null(list_of(non_null(:task)))) do
      resolve(&TodoResolver.all_tasks/3)
    end
  end

  mutation do
    field :create_task, :task do
      arg(:description, non_null(:string))
      resolve(&TodoResolver.create_task/3)
    end

    field :update_task, :task do
      arg(:id, non_null(:id))
      arg(:description, :string)
      arg(:done, :boolean)
      resolve(&TodoResolver.update_task/3)
    end
  end
end
