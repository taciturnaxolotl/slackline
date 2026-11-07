-module(slackline_test_ffi).
-export([record/1, recorded/0, first_time/1]).

%% A per-process log so tests can see which continuations ran.
record(Entry) ->
    put(slackline_test_log, [Entry | recorded_reversed()]),
    nil.

recorded() ->
    lists:reverse(recorded_reversed()).

recorded_reversed() ->
    case get(slackline_test_log) of
        undefined -> [];
        Log -> Log
    end.

%% True the first time a process asks about `Key`.
first_time(Key) ->
    case get({first_time, Key}) of
        undefined -> put({first_time, Key}, seen), true;
        _ -> false
    end.
