defmodule Streamr.StreamUploader do
  alias Streamr.{Repo, S3Service}
  alias Ecto.Adapters.SQL

  def process(stream) do
    stream
    |> write_to_file
    |> S3Service.upload_file(stream)
  end

  defp write_to_file(stream) do
    file_name = file_name_for(stream)
    create_file(file_name)

    Repo
    |> SQL.query!(stream_data_query(stream))
    |> Map.get(:rows)
    |> Parallel.pmap(pg_result_to_io())
    |> Enum.into(File.stream!(file_name))

    file_name
  end

  defp stream_data_query(stream) do
    """
      select line
      from stream_data
      left join lateral unnest(lines) as line on true
      where stream_id = #{stream.id}
      order by (line->>'time')::int asc
    """
  end

  defp file_name_for(stream) do
    "uploads/stream_upload_data_#{stream.id}"
  end

  defp create_file(name) do
    File.touch(name)
  end

  defp pg_result_to_io do
    fn [line] -> Poison.encode!(line) <> "\n" end
  end
end
