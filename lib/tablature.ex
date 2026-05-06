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
    |> Enum.map(fn index ->
      notes_at_position =
        Enum.map(lines, fn {string, notes} ->
          char = String.at(notes, index)

          cond do
            char == nil ->
              nil

            char =~ ~r/\d/ ->
              string <> char

            true ->
              nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      current_chars =
        Enum.map(lines, fn {_string, notes} ->
          String.at(notes, index)
        end)

      cond do
        notes_at_position != [] ->
          Enum.join(notes_at_position, "/")

        Enum.any?(current_chars, fn c -> c == "|" end) ->
          nil

        Enum.any?(current_chars, fn c -> c == "-" end) ->
          "_"

        true ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp split_line(line) do
    [string, notes] = String.split(line, "|", parts: 2)
    {string, notes}
  end
end
