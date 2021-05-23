defmodule Conduit.Accounts.Protocol.RegisterUser do
  @moduledoc """
  Register a new user.
  """

  use Cqrs.Command, dispatcher: Conduit.App

  alias Cqrs.CommandValidation
  alias Conduit.{Accounts, Auth}

  field :username, :string
  field :email, :string
  field :password, :string

  field :user_uuid, :binary_id, internal: true
  field :hashed_password, :string, internal: true

  derive_event UserRegistered, drop: [:password]

  @impl true
  def handle_validate(command, _opts) do
    import Ecto.Changeset

    command
    |> validate_format(:email, ~r/\S+@\S+\.\S+/, message: "is invalid")
    |> validate_format(:username, ~r/^[a-z0-9]+$/i, message: "is invalid")
  end

  @impl true
  def after_validate(%{username: username, email: email, password: password} = command) do
    command
    |> Map.put(:user_uuid, UUID.uuid4())
    |> Map.put(:email, String.downcase(email))
    |> Map.put(:username, String.downcase(username))
    |> Map.put(:hashed_password, Auth.hash_password(password))
  end

  @impl true
  def before_dispatch(command, opts) do
    command
    |> CommandValidation.new()
    |> CommandValidation.add(&ensure_email/1)
    |> CommandValidation.add(&ensure_username/1)
    |> CommandValidation.run(opts)
  end

  defp ensure_email(%{email: email}) do
    filters = [email: email]

    if Accounts.get_user(filters, exists?: true) do
      {:error, "email has already been taken"}
    end
  end

  defp ensure_username(%{username: username}) do
    filters = [username: username]

    if Accounts.get_user(filters, exists?: true) do
      {:error, "username has already been taken"}
    end
  end
end
