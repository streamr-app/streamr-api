defmodule Streamr.ColorControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  describe "GET /api/v1/colors" do
    setup do
      insert_list(2, :color)

      :ok
    end

    test "it returns all colors" do
      conn = get(
        build_conn(),
        "/api/v1/colors"
      )

      response = json_response(conn, 200)["data"]

      assert 2 == Enum.count(response)
    end
  end
end
