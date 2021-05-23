defmodule Conduit.Accounts.Aggregates.User do
  defstruct [
    :uuid,
    :username,
    :email,
    :hashed_password
  ]

  alias Conduit.Accounts.Aggregates.User

  alias Conduit.Accounts.Protocol.{RegisterUser, UserRegistered}
  alias Conduit.Accounts.Protocol.{UpdateUser, UserEmailChanged, UsernameChanged, UserPasswordChanged}

  @doc """
  Register a new user
  """
  def execute(%User{uuid: nil}, %RegisterUser{} = register) do
    UserRegistered.new(register)
  end

  @doc """
  Update a user's username, email, and password
  """
  def execute(%User{} = user, %UpdateUser{} = update) do
    Enum.reduce([&username_changed/2, &email_changed/2, &password_changed/2], [], fn change, events ->
      case change.(user, update) do
        nil -> events
        event -> [event | events]
      end
    end)
  end

  # state mutators

  def apply(%User{} = user, %UserRegistered{} = registered) do
    %User{
      user
      | uuid: registered.user_uuid,
        username: registered.username,
        email: registered.email,
        hashed_password: registered.hashed_password
    }
  end

  def apply(%User{} = user, %UsernameChanged{username: username}) do
    %User{user | username: username}
  end

  def apply(%User{} = user, %UserEmailChanged{email: email}) do
    %User{user | email: email}
  end

  def apply(%User{} = user, %UserPasswordChanged{hashed_password: hashed_password}) do
    %User{user | hashed_password: hashed_password}
  end

  # private helpers

  defp username_changed(%User{}, %UpdateUser{username: ""}), do: nil
  defp username_changed(%User{username: username}, %UpdateUser{username: username}), do: nil
  defp username_changed(%User{}, %UpdateUser{} = command), do: UsernameChanged.new(command)

  defp email_changed(%User{}, %UpdateUser{email: ""}), do: nil
  defp email_changed(%User{email: email}, %UpdateUser{email: email}), do: nil
  defp email_changed(%User{}, %UpdateUser{} = command), do: UserEmailChanged.new(command)

  defp password_changed(%User{}, %UpdateUser{hashed_password: ""}), do: nil
  defp password_changed(%User{hashed_password: pass}, %UpdateUser{hashed_password: pass}), do: nil
  defp password_changed(%User{}, %UpdateUser{} = command), do: UserPasswordChanged.new(command)
end
