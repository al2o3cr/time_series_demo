defmodule TimeSeriesDemoListTest do
  use ExUnit.Case
  doctest TimeSeriesDemoList

  setup_all do
    TimeSeriesDemoList.fill()
    assert_receive :loaded, 1200000
    :ok
  end

  test "retrieves records" do
    {elapsed, result} = :timer.tc(fn -> 
      TimeSeriesDemoList.get(%{id: 1, year: 2018, month: 3, day: 20, hour: 2})
    end)
    IO.inspect("RETRIEVE LIST: #{elapsed/1.0e6}")
    assert Enum.count(result) == 60
  end

  test "retrieves records out of order" do
    {elapsed, result} = :timer.tc(fn -> 
      TimeSeriesDemoList.get(%{id: :_, year: 2018, month: 3, day: 20, hour: 2, minute: 1, second: 1})
    end)
    IO.inspect("RETRIEVE LIST OOO: #{elapsed/1.0e6}")
    assert Enum.count(result) == 500
  end
end
