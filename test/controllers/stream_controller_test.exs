defmodule Streamr.StreamControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  describe "GET /api/v1/streams" do
    setup do
      insert_list(2, :stream)

      :ok
    end

    test "it returns all streams" do
      conn = get(
        build_conn(),
        "/api/v1/streams"
      )

      response = json_response(conn, 200)["data"]

      assert 2 == Enum.count(response)
    end
  end
end
