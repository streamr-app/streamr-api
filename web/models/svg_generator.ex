defmodule Streamr.SVGGenerator do
  alias Streamr.{Repo, Color}
  alias Ecto.Adapters.SQL

  def generate(stream) do
    filepaths = filepaths_for(stream)

    create_files(filepaths)
    draw_svg_paths(stream, filepaths)
    add_footer(filepaths)
    convert_to_png(filepaths)
  end

  defp convert_to_png(filepaths) do
    Parallel.pupdate filepaths, fn filepath ->
      new_filepath = String.replace_trailing(filepath, ".svg", ".png")

      System.cmd("convert", [
        filepath,
        "-size", "1920x1080",
        "-colorspace", "RGB",
        new_filepath
      ])

      new_filepath
    end
  end

  defp create_files(filepaths) do
    Enum.each Map.values(filepaths), fn filepath ->
      File.touch(filepath)
      File.write!(filepath, svg_header())
    end
  end

  defp draw_svg_paths(stream, filepaths) do
    stream
    |> generate_svg_paths()
    |> write_to_svgs(filepaths)
  end

  defp write_to_svgs(svg_paths, filepaths) do
    Parallel.peach filepaths, fn {palette, filepath} ->
      Enum.into(svg_paths, File.stream!(filepath, [:append]), fn (row) -> row[palette] end)
    end
  end

  defp generate_svg_paths(stream) do
    color_map = generate_color_map()
    last_clear_event_time = determine_last_clear_time(stream)

    Repo
    |> SQL.query!(stream_data_query(stream, last_clear_event_time))
    |> Map.get(:rows)
    |> Parallel.pmap(pg_result_to_io(color_map))
  end

  defp pg_result_to_io(color_map) do
    fn [row] -> generate_svg_path(row, color_map) end
  end

  defp generate_svg_path(row, color_map) do
    width = Map.get(row, "thickness") + 2
    suffix = line_cap(row)
    color_id = String.to_integer(row["color_id"])

    row
    |> Map.get("points")
    |> Enum.map(fn point -> "#{point["x"] * 1920},#{point["y"] * 1080}" end)
    |> Enum.join("L")
    |> generate_possible_paths(color_id, color_map, width, suffix)
  end

  defp generate_possible_paths(path, color_id, color_map, width, suffix) do
    Map.new Color.palettes, fn palette ->
      color = color_map[color_id][palette]

      {palette, ~s(<path stroke="#{color}" stroke-width="#{width}" d="M#{path}#{suffix}"></path>)}
    end
  end

  defp stream_data_query(stream, latest_clear_event) do
    """
      select line
      from stream_data
      left join lateral unnest(lines) as line on true
      where stream_id = #{stream.id}
        and line->>'type' = 'line'
        and line->>'line_id' not in (#{undo_events(stream)})
        #{limit_by_clear_event(latest_clear_event)}
      order by (line->>'time')::int asc
    """
  end

  defp limit_by_clear_event(nil), do: nil
  defp limit_by_clear_event(clear_event_time) do
    "and (line->>'time')::int > #{clear_event_time}"
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

  defp add_footer(filepaths) do
    Enum.each Map.values(filepaths), fn filepath ->
      File.write!(filepath, svg_footer(), [:append])
    end
  end

  defp filepaths_for(stream) do
    Color.palettes
    |> Enum.zip(unique_filenames(stream))
    |> Map.new()
  end

  defp unique_filenames(stream) do
    Enum.map Color.palettes, fn (palette) ->
      "uploads/stream_preview_#{stream.id}_" <> Atom.to_string(palette) <> ".svg"
    end
  end

  def generate_color_map do
    Map.new Repo.all(Color), fn (color) ->
      {
        color.id,
        %{
          normal: color.normal,
          deuteranopia: color.deuteranopia,
          protanopia: color.protanopia,
          tritanopia: color.tritanopia
        }
      }
    end
  end

  defp undo_events(stream) do
    """
      select line->>'line_id' from stream_data
      left join lateral unnest(lines) as line on true
      where stream_id = #{stream.id}
        and line->>'type' = 'undo'
    """
  end

  defp line_cap(row) do
    if Enum.count(row["points"]) == 1, do: "Z"
  end

  defp determine_last_clear_time(stream) do
    %{rows: [[time]]} = SQL.query!(
      Repo,
      """
        select max((line->>'time')::int)
        from stream_data
        left join lateral unnest(lines) as line on true
        where stream_id = #{stream.id}
          and line->>'type' = 'clear'
      """
    )

    time
  end
end
