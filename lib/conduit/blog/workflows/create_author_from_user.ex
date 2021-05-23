defmodule Conduit.Blog.Workflows.CreateAuthorFromUser do
  use Commanded.Event.Handler,
    application: Conduit.App,
    name: "Blog.Workflows.CreateAuthorFromUser",
    consistency: :strong

  alias Conduit.Blog
  alias Conduit.Accounts.Protocol.UserRegistered

  def handle(%UserRegistered{user_uuid: user_uuid, username: username}, _metadata) do
    with {:ok, _author} <- Blog.create_author(user_uuid: user_uuid, username: username) do
      :ok
    end
  end
end
