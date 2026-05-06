defmodule Tablature do
  def parse(tab) do
    tab
    |> split_segments()
    |> Enum.map(&parse_segment/1)
    |> Enum.join(" ")
    |> String.trim()
  end

  defp split_segments(tab) do
    tab
    |> String.trim()
    |> String.split(~r/\n\s*\n/, trim: true)
  end

  defp parse_segment(segment) do
    lines =
      segment
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)

    strings =
      Enum.map(lines, fn line ->
        [string, content] = String.split(line, "|", parts: 2)

        clean =
          content
          |> String.replace("|", "")

        {string, clean}
      end)

    max_len =
      strings
      |> Enum.map(fn {_s, c} -> String.length(c) end)
      |> Enum.max()

    {tokens, silence_count} =
      Enum.reduce(0..(max_len - 1), {[], 0}, fn idx, {acc, silence_count} ->
        notes =
          Enum.reduce(strings, [], fn {string, content}, note_acc ->
            current =
              if idx < String.length(content),
                do: String.at(content, idx),
                else: "-"

            cond do
              current =~ ~r/\d/ ->
                prev =
                  if idx > 0,
                    do: String.at(content, idx - 1),
                    else: "-"

                if prev =~ ~r/\d/ do
                  note_acc
                else
                  next =
                    if idx + 1 < String.length(content),
                      do: String.at(content, idx + 1),
                      else: ""

                  fret =
                    if next =~ ~r/\d/ do
                      current <> next
                    else
                      current
                    end

                  note_acc ++ ["#{string}#{fret}"]
                end

              true ->
                note_acc
            end
          end)

        cond do
          notes != [] ->
            silences =
              if silence_count >= 3 do
                List.duplicate("_", max(1, round(silence_count / 2)))
              else
                []
              end

            {
              acc ++ silences ++ [Enum.join(notes, "/")],
              0
            }

          true ->
            {acc, silence_count + 1}
        end
      end)

    final_tokens =
      if silence_count >= 3 do
        tokens ++ List.duplicate("_", max(1, round(silence_count / 2)))
      else
        tokens
      end

    final_tokens
    |> trim_edges()
    |> Enum.join(" ")
  end

  defp trim_edges(tokens) do
    tokens
    |> Enum.drop_while(&(&1 == "_"))
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == "_"))
    |> Enum.reverse()
  end
end
