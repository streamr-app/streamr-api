defmodule Streamr.SVGGenerator do
  import Ecto.Query

  alias Streamr.{Repo, Color}
  alias Ecto.Adapters.SQL

  def generate(stream) do
    filepath = filepath_for(stream)
    undo_table_name = undo_table_name_for(stream)

    create_undos_table(stream, undo_table_name)
    create_file(filepath)
    create_svg(stream, filepath, undo_table_name)
    drop_undos_table(undo_table_name)
    add_footer(filepath)
    convert_to_png(filepath)
  end

  defp convert_to_png(filepath) do
    new_filepath = String.replace_trailing(filepath, ".svg", ".png")

    System.cmd("convert", [
      filepath,
      "-size", "1920x1080",
      "-colorspace", "RGB",
      new_filepath
    ])

    new_filepath
  end

  defp create_file(filepath) do
    File.touch(filepath)
    File.write!(filepath, svg_header())
  end

  defp create_svg(stream, filepath, undo_table_name) do
    color_map = generate_color_map()
    last_clear_event_time = determine_last_clear_time(stream)

    Repo
    |> SQL.query!(stream_data_query(stream, undo_table_name, last_clear_event_time))
    |> Map.get(:rows)
    |> Parallel.pmap(pg_result_to_io(color_map))
    |> Enum.into(File.stream!(filepath, [:append]))
  end

  defp pg_result_to_io(color_map) do
    fn [row] -> generate_svg_path(row, color_map) end
  end

  defp generate_svg_path(row, color_map) do
    color = Map.get(color_map, String.to_integer(row["color_id"]))
    width = Map.get(row, "thickness") + 2
    suffix = line_cap(row)

    path = row
    |> Map.get("points")
    |> Enum.map(fn point -> "#{point["x"] * 1920},#{point["y"] * 1080}" end)
    |> Enum.join("L")

    ~s(<path stroke="#{color}" stroke-width="#{width}" d="M#{path}#{suffix}"></path>)
  end

  def stream_data_query(stream, undo_table_name, latest_clear_event) do
    """
      select line
      from stream_data
      left join lateral unnest(lines) as line on true
      left join #{undo_table_name} on #{undo_table_name}.undo->>'line_id' = line->>'line_id'
      where stream_id = #{stream.id}
        and line->>'type' = 'line'
        and #{undo_table_name}.undo is null
        and (line->>'time')::int > #{latest_clear_event}
      order by (line->>'time')::int asc
    """
  end

  defp svg_header do
    """
      <svg viewBox="0 0 1920 1080"><g fill="none">
        <rect x="0" y="0" width="1920" height="1080" fill="rgb(19,22,27)"></rect>
    """
  end

  defp svg_footer do
    "</g></svg>"
  end

  defp add_footer(filepath) do
    File.write!(filepath, svg_footer(), [:append])
  end

  defp filepath_for(stream) do
    "uploads/stream_preview_#{stream.id}.svg"
  end

  defp generate_color_map do
    Repo.all(from c in Color, select: {c.id, c.normal})
    |> Enum.into(%{})
  end

  defp undo_table_name_for(stream) do
    "svg_generation_data_#{stream.id}"
  end

  defp create_undos_table(stream, table_name) do
    SQL.query!(
      Repo,
      """
       create table if not exists #{table_name} as
       select line as undo from stream_data
       left join lateral unnest(lines) as line on true
       where stream_id = #{stream.id}
         and line->>'type' = 'undo'
      """
    )
  end

  defp drop_undos_table(undo_table_name) do
    SQL.query(Repo, "drop table #{undo_table_name}")
  end

  defp line_cap(row) do
    if Enum.count(row["points"]) == 1, do: "Z"
  end

  defp determine_last_clear_time(stream) do
    %{rows: [[time]]} = SQL.query!(
      Repo,
      """
        select coalesce(max((line->>'time')::int), 0)
        from stream_data
        left join lateral unnest(lines) as line on true
        where stream_id = #{stream.id}
          and line->>'type' = 'clear'
      """
    )

    time
  end
end
