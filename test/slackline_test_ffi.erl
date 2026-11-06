-module(slackline_test_ffi).
-export([record/1, recorded/0]).

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
