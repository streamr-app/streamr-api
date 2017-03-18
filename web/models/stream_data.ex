defmodule Streamr.StreamData do
  use Streamr.Web, :model
  import Ecto.Query

  alias Streamr.{Repo, StreamData}
  alias Ecto.Adapters.SQL

  schema "stream_data" do
    field :lines, {:array, :map}
    belongs_to :stream, Streamr.Stream

    timestamps()
  end

  def for_stream(stream) do
    Repo.one(
      from data in StreamData,
      where: data.stream_id == ^stream.id
    )
  end

  def initialize_for(stream) do
    stream
    |> Ecto.build_assoc(:stream_data, lines: [])
    |> Repo.insert
  end

  def append_to(stream, line_data) do
    SQL.query(Repo, append_query(stream, line_data))
  end

  def append_query(stream, line_data) do
    """
      update stream_data
        set lines = array_append(lines, '#{Poison.encode!(line_data)}'::json)
      where stream_id = #{stream.id}
    """
  end
end
