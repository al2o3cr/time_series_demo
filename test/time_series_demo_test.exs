defmodule TimeSeriesDemoTest do
  use ExUnit.Case
  doctest TimeSeriesDemo

  setup_all do
    TimeSeriesDemo.fill()
    assert_receive :loaded, 1200000
    :ok
  end

  test "retrieves records" do
    {elapsed, result} = :timer.tc(fn -> 
      TimeSeriesDemo.get(%{id: 1, year: 2018, month: 3, day: 20, hour: 2})
    end)
    IO.inspect("RETRIEVE MNESIA: #{elapsed/1.0e6}")
    assert Enum.count(result) == 60
  end

  test "retrieves records out of order" do
    {elapsed, result} = :timer.tc(fn -> 
      TimeSeriesDemo.get(%{id: :_, year: 2018, month: 3, day: 20, hour: 2, minute: 1, second: 1})
    end)
    IO.inspect("RETRIEVE MNESIA OOO: #{elapsed/1.0e6}")
    assert Enum.count(result) == 500
  end
end
