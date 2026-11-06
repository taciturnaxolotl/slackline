-module(slackline_live_ffi).
-export([getenv/1, write_file/2, read_file/1, halt/1, unique/0]).

getenv(Name) ->
    case os:getenv(binary_to_list(Name)) of
        false -> {error, nil};
        Value -> {ok, unicode:characters_to_binary(Value)}
    end.

write_file(Path, Contents) ->
    ok = filelib:ensure_dir(Path),
    case file:write_file(Path, Contents) of
        ok -> {ok, nil};
        {error, _} -> {error, nil}
    end.

halt(Code) -> erlang:halt(Code).

read_file(Path) ->
    case file:read_file(Path) of
        {ok, Contents} -> {ok, Contents};
        {error, _} -> {error, nil}
    end.

unique() -> erlang:unique_integer([positive, monotonic]).
