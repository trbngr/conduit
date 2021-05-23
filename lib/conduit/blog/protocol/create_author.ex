defmodule Conduit.Blog.Protocol.CreateAuthor do
  @moduledoc """
  Create an author.

  An author shares the same uuid as the user, but with a different prefix.
  """

  use Cqrs.Command, dispatcher: Conduit.App

  field :author_uuid, :binary_id, internal: true

  field :user_uuid, :binary_id
  field :username, :string

  derive_event AuthorCreated

  @impl true
  def handle_validate(command, _opts) do
    import Ecto.Changeset

    validate_format(command, :username, ~r/^[a-z0-9]+$/i, message: "is invalid")
  end
end
