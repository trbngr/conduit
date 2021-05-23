defmodule Conduit.Accounts.Queries.GetUser do
  use Cqrs.Query
  alias Conduit.Accounts.Projections.User

  filter :user_uuid, :binary_id
  filter :user_uuid_not, :binary_id
  filter :username, :string
  filter :email, :string

  binding :user, User

  option :exists?, :boolean,
    default: false,
    description: "If `true`, checks if there exists an entry that matches the query and returns a boolean"

  @impl true
  def handle_create([], _opts), do: {:error, "requires at least one filter"}

  @impl true
  def handle_create(filters, _opts) do
    query = from(u in User, as: :user)

    Enum.reduce(filters, query, fn
      {:user_uuid, uuid}, query -> from u in query, where: u.uuid == ^uuid
      {:user_uuid_not, uuid}, query -> from u in query, where: u.uuid != ^uuid
      {:email, email}, query -> from u in query, where: u.email == ^email
      {:username, username}, query -> from u in query, where: u.username == ^username
    end)
  end

  @impl true
  def handle_execute(query, opts), do: do_execute(:one, query, opts)

  @impl true
  def handle_execute!(query, opts), do: do_execute(:one!, query, opts)

  defp do_execute(repo_fun, query, opts) do
    alias Conduit.Repo

    if Keyword.fetch!(opts, :exists?),
      do: Repo.exists?(query, opts),
      else: apply(Repo, repo_fun, [query, opts])
  end
end
