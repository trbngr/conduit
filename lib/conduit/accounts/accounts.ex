defmodule Conduit.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """
  use Cqrs.BoundedContext

  alias Conduit.Accounts.Queries.GetUser
  alias Conduit.Accounts.Protocol.{RegisterUser, UpdateUser}

  query GetUser

  command RegisterUser, then: &fetch_user/1, consistency: :strong
  command UpdateUser, then: &fetch_user/1, consistency: :strong

  defp fetch_user(result) do
    with {:ok, %{aggregate_state: %{uuid: uuid}}} <- result do
      get_user(user_uuid: uuid)
    end
  end
end
