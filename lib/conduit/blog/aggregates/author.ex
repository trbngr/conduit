defmodule Conduit.Blog.Aggregates.Author do
  defstruct uuid: nil,
            user_uuid: nil,
            username: nil,
            bio: nil,
            image: nil,
            followed_by_authors: MapSet.new()

  alias Conduit.Blog.Aggregates.Author

  alias Conduit.Blog.Protocol.{CreateAuthor, AuthorCreated}
  alias Conduit.Blog.Protocol.{FollowAuthor, AuthorFollowed}

  alias Conduit.Blog.Commands.{UnfollowAuthor}
  alias Conduit.Blog.Events.{ AuthorUnfollowed}

  @doc """
  Creates an author
  """
  def execute(%Author{uuid: nil}, %CreateAuthor{} = create) do
    AuthorCreated.new(create)
  end

  def execute(%Author{uuid: author_uuid} = author, %FollowAuthor{follower_uuid: follower_uuid}) do
    case is_follower?(author, follower_uuid) do
      true ->
        nil

      false ->
        %AuthorFollowed{
          author_uuid: author_uuid,
          followed_by_author_uuid: follower_uuid
        }
    end
  end

  def execute(%Author{uuid: author_uuid} = author, %UnfollowAuthor{unfollower_uuid: follower_uuid}) do
    case is_follower?(author, follower_uuid) do
      true ->
        %AuthorUnfollowed{
          author_uuid: author_uuid,
          unfollowed_by_author_uuid: follower_uuid
        }

      false ->
        nil
    end
  end

  # state mutators

  def apply(%Author{} = author, %AuthorCreated{} = created) do
    %Author{
      author
      | uuid: created.author_uuid,
        user_uuid: created.user_uuid,
        username: created.username
    }
  end

  def apply(%Author{followed_by_authors: followers} = author, %AuthorFollowed{
        followed_by_author_uuid: follower_uuid
      }) do
    %Author{author | followed_by_authors: MapSet.put(followers, follower_uuid)}
  end

  def apply(%Author{followed_by_authors: followers} = author, %AuthorUnfollowed{
        unfollowed_by_author_uuid: unfollower_uuid
      }) do
    %Author{author | followed_by_authors: MapSet.delete(followers, unfollower_uuid)}
  end

  # private helpers

  defp is_follower?(%Author{followed_by_authors: followers}, follower_uuid) do
    MapSet.member?(followers, follower_uuid)
  end
end
