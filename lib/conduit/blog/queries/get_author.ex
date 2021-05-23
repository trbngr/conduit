defmodule Conduit.Blog.Queries.GetAuthor do
  use Cqrs.Query

  alias Conduit.{Blog.Projections.Author, Repo}

  filter :uuid, :binary
  filter :username, :string

  binding :author, Author

  @impl true
  def handle_create(filters, _opts) do
    query = from(a in Author, as: :author)

    Enum.reduce(filters, query, fn
      {:uuid, uuid}, query -> from a in query, where: a.uuid == ^uuid
      {:username, username}, query -> from a in query, where: a.username == ^username
    end)
  end

  @impl true
  def handle_execute(query, opts), do: Repo.one(query, opts)

  @impl true
  def handle_execute!(query, opts), do: Repo.one!(query, opts)
end
