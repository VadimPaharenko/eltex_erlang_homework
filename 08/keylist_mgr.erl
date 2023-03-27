-module(keylist_mgr).
-export([loop/1]).
-export([start/0]).

-record(state,{
    children = [] :: list
}).

loop(#state{children = Children} = State) when is_list(Children) ->
    process_flag(trap_exit, true),
    receive
        {From, start_child, Name} ->
            case proplists:is_defined(Name, Children) of
                true -> 
                    From ! {ok, process_is_alredy_started},
                    loop(State);
                false -> 
                    Pid = keylist:start_link(Name),
                    NewState = State#state{children = [{Name, Pid} | Children]},
                    From ! {ok, Pid},
                    loop(NewState)
            end;
        {From, stop_child, Name} ->
            case proplists:is_defined(Name, Children) of
                true ->
                    exit(whereis(Name), stop_child),
                    NewState = State#state{children = proplists:delete(Name, Children)},
                    From ! {ok, NewState},
                    loop(NewState);
                false ->
                    From ! {ok, process_does_not_exist},
                    loop(State)
            end;
        stop ->
            process_flag(trap_exit, false),
            exit(whereis(?MODULE), stop_command);
        {From, get_names} ->
            Proc_Names = [X || {X,_} <- Children],
            From ! lists:reverse(Proc_Names),
            loop(State);
        {'EXIT', Pid, Reason} ->
            case lists:keyfind(Pid, 2, Children) of
                {Proc_name, Pid} -> 
                    NewState = State#state{children = proplists:delete(Proc_name, Children)},
                    io:format("Down process ~p with reason ~p ~n",[Pid, Reason]),
                    loop(NewState);
                false ->
                    io:format("Process with Pid ~p undefined ~n",[Pid]),
                    loop(State)
            end
    end.


start() ->
    Pid = spawn(?MODULE, loop, [#state{}]),
    register(?MODULE, Pid),
    MonitorRef = monitor(process, Pid),
    {ok, Pid, MonitorRef}.