defmodule Conduit.Blog.Protocol.FollowAuthor do
  use Cqrs.Command, dispatcher: Conduit.App

  field :author_uuid, :binary_id
  field :follower_uuid, :binary_id

  derive_event AuthorFollowed, with: [:followed_by_author_uuid], drop: [:follower_uuid]
end
