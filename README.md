# TimeSeriesDemo

Demonstrates using `mnesia_eleveldb` to store time-series data & the speed benefits of prefix matching

## Details

To allow ranges of time to be retrieved efficiently, they are stored as tuples:

```
{item_id, year, month, day, hour, minute, sec}
```

`item_id` is a generic "entity label".

`mnesia_eleveldb` encodes this tuple in a way that makes prefix matching very efficient, allowing retrieval of "all data for this month / hour / minute etc".

Run the tests with `mix test`. They print some timing diagnostics; on my machine (2017 15" MBP 16GB):

```
LOADED LIST in 275.705315 sec
RETRIEVE LIST OOO: 0.724892
RETRIEVE LIST: 0.448813

LOADED MNESIA in 396.334065 sec
RETRIEVE MNESIA OOO: 67.682154
RETRIEVE MNESIA: 0.002465
```

Note that the out-of-order test (which uses a wildcard `item_id`) is very slow for Mnesia, but the other test which allows for prefix matching is very fast.

See also:

* [`mnesia_leveldb`](https://github.com/klarna/mnesia_eleveldb)
* [mnesia + leveldb: liberating mnesia from the limitations of DETS](http://www.erlang-factory.com/euc2015/mikael-pettersson) by Mikael Pettersson at Erlang Factory 2015

