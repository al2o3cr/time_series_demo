defmodule TimeSeriesDemoList do
  @moduledoc """
  Exposes the same interface but uses plain lists
  """

  use GenServer

  def get(%{id: id, year: year, month: month, day: day, hour: hour, minute: minute, sec: sec}) do
    key = {id, year, month, day, hour, minute, sec}
    GenServer.call(__MODULE__, {:get, key}, 60000)
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
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:get, {key_id, key_year, key_month, key_day, key_hour, key_minute, key_sec}}, _from, state) do
    results = Enum.filter(state, fn({{id, year, month, day, hour, minute, sec}, _val}) ->
      ((key_id == :_) || (key_id == id)) &&
      ((key_year == :_) || (key_year == year)) &&
      ((key_month == :_) || (key_month == month)) &&
      ((key_day == :_) || (key_day == day)) &&
      ((key_hour == :_) || (key_hour == hour)) &&
      ((key_minute == :_) || (key_minute == minute)) &&
      ((key_sec == :_) || (key_sec == sec))
    end)
    {:reply, results, state}
  end

  @impl GenServer
  def handle_cast({:fill, pid}, _state) do
    {elapsed, new_state} = :timer.tc(fn ->
      Enum.flat_map(1..500, fn(item_id) ->
        # IO.inspect("LOADED LIST #{item_id}")
        fill_records(item_id)
      end)
    end)
    IO.inspect("LOADED LIST in #{elapsed/1.0e6} sec")
    send(pid, :loaded)
    {:noreply, new_state}
  end

  defp fill_records(item_id) do
    start_time = Calendar.DateTime.from_erl!({{2018, 03, 20}, {0, 0, 1}}, "MST")
    Enum.map(0..10000, fn(offset) ->
      t = Calendar.DateTime.add!(start_time, 60*offset)
      key = {item_id, t.year, t.month, t.day, t.hour, t.minute, t.second}
      {key, t}
    end)
  end
end
