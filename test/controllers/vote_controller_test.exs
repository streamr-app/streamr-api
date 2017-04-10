defmodule Streamr.VoteControllerTest do
  use Streamr.ConnCase
  import Streamr.Factory

  describe "POST /api/v1/streams/:id/my_vote" do
    test "it creates a new vote for the stream from the user" do
      stream = insert(:stream)
      user = insert(:user)

      conn = post_authorized(user, "/api/v1/streams/#{stream.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(stream) == 1
    end

    test "it does not create duplicate my_vote for the same user" do
      stream = insert(:stream)
      user = insert(:user)
      Streamr.VoteManager.create(user, %{"stream_id" => stream.id})

      conn = post_authorized(user, "/api/v1/streams/#{stream.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(stream) == 1
    end

    test "it requires users to be signed in" do
      conn = post(build_conn(), "/api/v1/streams/#{insert(:stream).id}/my_vote")

      assert conn.status == 401
    end
  end

  describe "POST /api/v1/comments/:id/my_vote" do
    test "it creates a new vote for the comment from the user" do
      comment = insert(:comment)
      user = insert(:user)

      conn = post_authorized(user, "/api/v1/comments/#{comment.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(comment) == 1
    end

    test "it does not create duplicate my_vote for the same user" do
      comment = insert(:comment)
      user = insert(:user)
      Streamr.VoteManager.create(user, %{"comment_id" => comment.id})

      conn = post_authorized(user, "/api/v1/comments/#{comment.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(comment) == 1
    end

    test "it requires users to be signed in" do
      conn = post(build_conn(), "/api/v1/comments/#{insert(:comment).id}/my_vote")

      assert conn.status == 401
    end
  end

  describe "DELETE /api/v1/streams/:id/my_vote" do
    test "it removes my vote when I have voted on the stream" do
      stream = insert(:stream)
      user = insert(:user)
      Streamr.VoteManager.create(user, %{"stream_id" => stream.id})

      conn = delete_authorized(user, "/api/v1/streams/#{stream.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(stream) == 0
    end

    test "it returns a 422 if I have not voted on the stream" do
      stream = insert(:stream)
      user = insert(:user)

      conn = delete_authorized(user, "/api/v1/streams/#{stream.id}/my_vote")

      assert conn.status == 204
    end

    test "it requires users to be signed in" do
      conn = delete(build_conn(), "/api/v1/streams/#{insert(:stream).id}/my_vote")

      assert conn.status == 401
    end
  end

  describe "DELETE /api/v1/comments/:id/my_vote" do
    test "it removes my vote when I have voted on the comment" do
      comment = insert(:comment)
      user = insert(:user)
      Streamr.VoteManager.create(user, %{"comment_id" => comment.id})

      conn = delete_authorized(user, "/api/v1/comments/#{comment.id}/my_vote")

      assert conn.status == 204
      assert Streamr.Vote.count(comment) == 0
    end

    test "it returns a 422 if I have not voted on the comment" do
      comment = insert(:comment)
      user = insert(:user)

      conn = delete_authorized(user, "/api/v1/streams/#{comment.id}/my_vote")

      assert conn.status == 204
    end

    test "it requires users to be signed in" do
      conn = delete(build_conn(), "/api/v1/comments/#{insert(:comment).id}/my_vote")

      assert conn.status == 401
    end
  end
end
