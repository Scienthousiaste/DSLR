defmodule Statistics do

  def count(data) do
    Enum.reduce data, 0,
      fn _element, acc -> acc + 1 end
  end

  def sum(data) do
    Enum.reduce data, 
      fn element, acc when is_number element -> acc + element end
  end

  def mean(data) do
    sum(data) / count(data)
  end

  def std(data) do
    (variance data) |> :math.sqrt  
  end

  def variance(data) do
    data_mean = mean(data)
    data_count = count(data)
    (1 / data_count) * Enum.reduce data, 0,
      fn element, acc -> acc + (element - data_mean) * (element - data_mean) end
  end

  def min(data) do
    Enum.reduce data,
      fn 
        element, acc when element < acc -> element
        _, acc -> acc
      end
  end

  def max(data) do
    Enum.reduce data,
      fn 
        element, acc when element > acc -> element
        _, acc -> acc
      end
  end

  def percentile(data, pc) do
    Enum.at(
      Enum.sort(data),
      trunc(pc * count(data))
    )
  end

  def median(data) do
    percentile(data, 0.5)
  end

end



