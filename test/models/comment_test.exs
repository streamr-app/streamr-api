defmodule Streamr.CommentTest do
  use Streamr.ConnCase
  alias Streamr.{Repo, Comment}

  import Streamr.Factory

  describe ".ordered" do
    test "returns newest comments first" do
      stream = insert(:stream)
      oldest = insert_comment(stream, 5)
      newest = insert_comment(stream, 0)
      middle = insert_comment(stream, 3)

      comment_ids = stream.id
                    |> Comment.for_stream()
                    |> Comment.ordered()
                    |> Repo.all()
                    |> Enum.map(&(&1.id))

      assert comment_ids == [newest.id, middle.id, oldest.id]
    end
  end

  defp insert_comment(stream, offset) do
    :comment |> build(stream: stream, inserted_at: days_ago(offset)) |> insert
  end

  defp days_ago(offset) do
    Timex.now() |> Timex.shift(days: -1 * offset)
  end
end
