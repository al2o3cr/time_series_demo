defmodule TimeSeriesDemo do
  @moduledoc """
  Interface to manipulate time-series data in mnesia_leveldb
  """

  use GenServer

  def get(%{id: id, year: year, month: month, day: day, hour: hour, minute: minute, sec: sec}) do
    key = {id, year, month, day, hour, minute, sec}
    GenServer.call(__MODULE__, {:get, key}, 6000000)
  end
  def get(%{id: id, year: year, month: month, day: day, hour: hour, minute: minute}), do: get(%{id: id, year: year, month: month, day: day, hour: hour, minute: minute, sec: :_})
  def get(%{id: id, year: year, month: month, day: day, hour: hour}), do: get(%{id: id, year: year, month: month, day: day, hour: hour, minute: :_, sec: :_})
  def get(%{id: id, year: year, month: month, day: day}), do: get(%{id: id, year: year, month: month, day: day, hour: :_, minute: :_, sec: :_})
  def get(%{id: id, year: year, month: month}), do: get(%{id: id, year: year, month: month, day: :_, hour: :_, minute: :_, sec: :_})
  def get(%{id: id, year: year}), do: get(%{id: id, year: year, month: :_, day: :_, hour: :_, minute: :_, sec: :_})
  def get(%{id: id}), do: get(%{id: id, year: :_, month: :_, day: :_, hour: :_, minute: :_, sec: :_})

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def fill do
    GenServer.cast(__MODULE__, {:fill, self()})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:all, _from, state) do
    {:reply, :mnesia.dirty_match_object({:time_series_data, {:_,:_,:_,:_,:_,:_,:_}, :_}), state}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    {:reply, :mnesia.dirty_match_object({:time_series_data, key, :_}), state}
  end

  @impl GenServer
  def handle_cast({:fill, pid}, _state) do
    {elapsed, new_state} = :timer.tc(fn ->
      Enum.each(1..500, fn(item_id) ->
        # IO.inspect("LOADING MNESIA #{item_id}")
        fill_records(item_id)
      end)
    end)
    IO.inspect("LOADED MNESIA in #{elapsed/1.0e6} sec")
    send(pid, :loaded)
    {:noreply, new_state}
  end

  defp fill_records(item_id) do
    start_time = Calendar.DateTime.from_erl!({{2018, 03, 20}, {0, 0, 1}}, "MST")
    Enum.each(0..10000, fn(offset) ->
      t = Calendar.DateTime.add!(start_time, 60*offset)
      tuple = {item_id, t.year, t.month, t.day, t.hour, t.minute, t.second}
      :mnesia.dirty_write({:time_series_data, tuple, t})
    end)
  end
end
