defmodule Describe do
  def main(filename) do
    case File.read(filename) do
      {:ok, file_content} -> parse_and_process_csv(String.trim(file_content))
      {:error, _reason} -> "The " <> filename <> " file does not exist"
    end
  end
  
  def parse_and_process_csv(filename) do
    case parse_csv(filename) do
      {:ok, csv_data} -> process_csv(csv_data)
      {:error, _reason} -> "The CSV is not well formatted"
    end
  end

  def process_csv({col_number, headers, lines}) do
    IO.inspect(headers)
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
end
