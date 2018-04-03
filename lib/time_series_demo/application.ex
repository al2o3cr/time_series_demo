defmodule TimeSeriesDemo.Application do
  use Application

  def start(_type, _args) do
    children = [
      TimeSeriesDemo,
      TimeSeriesDemoList
    ]

    :mnesia.create_schema([node()])
    :mnesia.start()
    :mnesia_eleveldb.register()
    :mnesia.create_table(:time_series_data,
                         type: :set,
                         leveldb_copies: [node()])

    opts = [strategy: :one_for_one, name: TimeSeriesDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

