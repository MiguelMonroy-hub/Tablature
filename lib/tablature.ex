defmodule Tablature do
  def parse(tab) do
    tab
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.zip()
    |> Enum.flat_map(&Tuple.to_list/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp parse_line(line) do
    [string, notes] = String.split(line, "|", parts: 2)

    Regex.scan(~r/\d+|-/, notes)
    |> List.flatten()
    |> Enum.map(fn
      "-" -> nil
      note -> string <> note
    end)
  end
end
