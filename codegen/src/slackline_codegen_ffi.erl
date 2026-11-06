-module(slackline_codegen_ffi).
-export([format_directory/1, halt/1, enter_project_root/0]).

%% The tools live in codegen/ but read and write the slackline project
%% around it, so they work from either directory.
enter_project_root() ->
    case {filelib:is_dir("spec"), filelib:is_dir("../spec")} of
        {false, true} -> ok = file:set_cwd("..");
        _ -> ok
    end,
    nil.

%% Runs `gleam format` on every Gleam file in Directory.
format_directory(Directory) ->
    Gleam = case os:find_executable("gleam") of
        false -> "gleam";
        Found -> Found
    end,
    Port = open_port({spawn_executable, Gleam}, [
        {args, ["format", Directory]},
        binary, exit_status, stderr_to_stdout, use_stdio
    ]),
    collect(Port, []).

collect(Port, Acc) ->
    receive
        {Port, {data, Data}} -> collect(Port, [Data | Acc]);
        {Port, {exit_status, 0}} -> {ok, nil};
        {Port, {exit_status, _}} ->
            {error, iolist_to_binary(lists:reverse(Acc))}
    end.

halt(Code) -> erlang:halt(Code).
