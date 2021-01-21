defmodule Describe do
  def main(filename) do
    case File.read(filename) do
      {:ok, file_content} -> parse_and_process_csv(String.trim(file_content))
      {:error, _reason} -> "The " <> filename <> " file does not exist"
    end
  end

  def parse_and_process_csv(filename) do
    case parse_csv(filename) do
      {:ok, csv_data} -> describe_numeric_variables(csv_data)
      {:error, _reason} -> "The CSV is not well formatted"
    end
  end

  def parse_csv(input) do
    [header_line | lines] = String.split(input, "\n")
    split_comma = fn str -> String.split(str, ",") end
    col_number = Enum.count(split_comma.(header_line))

    case Enum.any?(
      tl(lines), 
      fn line -> Enum.count(split_comma.(line)) !== col_number end
    ) do
      true -> {:error, "Line with column number different from the number of headers"}
      false -> {:ok, 
          {
            col_number,
            split_comma.(header_line), 
            Enum.map(lines, fn line -> String.split(line, ",") end)
          }
      }
    end
  end

  def describe_numeric_variables(csv_data) do
    csv_data
    |> make_dataframe
    |> filter_non_numeric_variables
    |> compute_statistics
    |> format_output
  end

  def make_dataframe({col_number, headers, lines}) do
    dataframe = Enum.reduce 0..col_number-1, %{},
      fn col, acc -> 
        Map.put(acc,
          Enum.at(headers, col),
          Enum.map(lines, fn line -> Enum.at(line, col) end)
        )
      end
    {headers, dataframe}
  end

  def filter_non_numeric_variables({headers, dataframe}) do
    numeric_variables_headers = Enum.filter headers,
      fn header -> 
        data = dataframe[header]
        (Enum.any? data, fn v -> v !== "" end) and
        is_empty_or_float?(data)
      end

    {numeric_variables_headers, dataframe}
  end

  def is_empty_or_float?(list) do
    Enum.all? list, fn v -> 
      case v do
        "" -> true
        v2 -> case (Float.parse v2) do
          {_, ""} -> true
          _ -> false
        end
      end
    end
  end

  def compute_statistics({headers, dataframe}) do
    Enum.map headers, fn header -> 
      data = Enum.map dataframe[header], fn v -> 
        case Float.parse v do
          {x, _} -> x
          _ -> 0.0
        end
      end
      [
        {:name, header},
        {:count, Statistics.count data},
        {:mean, Statistics.mean data},
        {:std, Statistics.std data},
        {:min, Statistics.min data},
        {:"25%", Statistics.percentile(data, 0.25)},
        {:"50%", Statistics.median data},
        {:"75%", Statistics.percentile(data, 0.75)},
        {:max, Statistics.max data},
      ]
    end

  end

  def format_output(input) do
    # N'afficher que de quoi remplir la largeur du terminal, and repeat!!
    # dans le terminal : tput cols (il y a aussi tput lines)
    
    {tput_cols, err} = System.cmd("tput", ["cols"])
  #  if (err) ...

    cols = (String.trim tput_cols) |> String.to_integer

    field_width = "16"
    format_header = String.duplicate(("~" <> field_width <> ".. s"), Enum.count(input) + 1)
    headers = [""] ++ Enum.map input, fn el -> el[:name] end
  
    IO.puts(:io.format(format_header, headers))
  end
end
