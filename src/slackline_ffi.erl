-module(slackline_ffi).
-export([javascript_only/2, javascript_only/3, javascript_only/5, now_seconds/0]).

javascript_only(_, _) ->
    erlang:error(slackline_fetch_is_javascript_only).

javascript_only(_, _, _) ->
    erlang:error(slackline_fetch_is_javascript_only).

javascript_only(_, _, _, _, _) ->
    erlang:error(slackline_fetch_is_javascript_only).

now_seconds() ->
    erlang:system_time(second).
