defmodule Tablature do
  def parse(tab) do
    lines =
      tab
      |> String.split("\n", trim: true)
      |> Enum.map(&split_line/1)

    max_length =
      lines
      |> Enum.map(fn {_string, notes} -> String.length(notes) end)
      |> Enum.max()

    0..(max_length - 1)
    |> Enum.flat_map(fn index ->
      Enum.map(lines, fn {string, notes} ->
        char = String.at(notes, index)

        if char =~ ~r/\d/ do
          string <> char
        else
          nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp split_line(line) do
    [string, notes] = String.split(line, "|", parts: 2)
    {string, notes}
  end
end
