defmodule Streamr.TopicControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  describe "GET /api/v1/topics" do
    setup do
      insert_list(2, :topic)

      :ok
    end

    test "it returns all topics" do
      conn = get(
        build_conn(),
        "/api/v1/topics"
      )

      response = json_response(conn, 200)["data"]

      assert 2 == Enum.count(response)
    end
  end
end
