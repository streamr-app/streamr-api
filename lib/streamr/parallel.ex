defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end

  def peach(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.each(&Task.await/1)
  end

  def pupdate(map, func) do
    Map.keys(map)
    |> Enum.zip(pmap(Map.values(map), func))
    |> Map.new()
  end
end
