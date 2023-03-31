-module(keylist_mgr).
-export([loop/1]). %% Callback
-export([start/0, start_child/1, stop_child/1, stop_process/0, get_names/0]). %% API

-record(state,{
    children = [] :: list,
    permanent = [] :: list
}).

%% @doc API function for spawn_monitor and register new process
-spec(start() -> 
    {ok, Pid :: pid(), MonitorRef :: reference()}).
start() ->
    {Pid, MonitorRef} = spawn_monitor(?MODULE, loop, [#state{}]),
    register(?MODULE, Pid),
    {ok, Pid, MonitorRef}.

%% @doc API function for send message {self(), start_child, Params when Params :: #{name => atom(), restart => permanent | temporary}}
%% to keylist_mgr process.
-spec(start_child(Params :: #{name => atom(), restart => permanent | temporary}) ->
    no_return() | badarg).
start_child(Params) ->
    case Params of
        #{name := _Proc_Name , restart := _Restart} ->
            keylist_mgr ! {self(), start_child, Params};
        _ ->
            badarg
    end.

%% @doc API function for send message {self(), stop_child, Name} to keylist_mgr process
-spec(stop_child(Name :: atom()) ->
    no_return()).
stop_child(Name) ->
    keylist_mgr ! {self(), stop_child, Name}.

%% @doc API function for send message stop to keylist_mgr process
-spec(stop_process() ->
    no_return()).
stop_process() ->
    keylist_mgr ! stop.

%% @doc API function for send message {self(), get_names} to keylist_mgr process
-spec(get_names() ->
    no_return()).
get_names() ->
    keylist_mgr ! {self(), get_names}.

%% @doc functions processes incoming keylist_mgr messages. 
%% can spawn_link new processes, delete processes, give names of already running processes, restart or log exit processes or exit main process keylist_mgr.
%% All names process and parametrs stored in record State.
-spec(loop(#state{children :: list(), permanent :: list()}) ->
    no_return()).
loop(#state{children = Children, permanent = Permanent} = State) when is_list(Children), is_list(Permanent) ->
    process_flag(trap_exit, true),
    receive
        {From, start_child, #{name := Name, restart := Restart}} when is_atom(Name), is_atom(Restart) ->
            case proplists:is_defined(Name, Children) of
                true -> 
                    io:format("Process ~p is alredy started  ~n",[Name]),
                    From ! {ok, process_is_alredy_started},
                    loop(State);
                false -> 
                    Pid = keylist:start_link(Name),
                    case Restart of
                        permanent -> 
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = [Pid | Permanent]};
                        temporary ->
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = Permanent}
                    end,
                    From ! {ok, Pid},
                    loop(NewState)
            end;
        {From, stop_child, Name} ->
            case proplists:is_defined(Name, Children) of
                true ->
                    exit(whereis(Name), stop_child),
                    NewState = State#state{children = proplists:delete(Name, Children), permanent = lists:delete(whereis(Name), Permanent)},
                    From ! {ok, NewState},
                    loop(NewState);
                false ->
                    From ! undefined,
                    loop(State)
            end;
        stop ->
            lists:foreach(
                fun({Name, _Pid}) ->
                    keylist:stop(Name)
                end,
                State#state.children);
        {From, get_names} ->
            Proc_Names = [X || {X,_} <- Children],
            From ! lists:reverse(Proc_Names),
            loop(State);
        {'EXIT', Pid, Reason} ->
            case lists:keyfind(Pid, 2, Children) of
                {Proc_name, Pid} -> 
                    case lists:member(Pid, Permanent) of
                        true ->
                            New_Pid = keylist:start_link(Proc_name),
                            NewState = State#state{children = Children, permanent = [New_Pid | lists:delete(Pid, Permanent)]},
                            io:format("Down process ~p with reason ~p, restarted with new pid ~p ~n",[Proc_name, Reason, New_Pid]);
                        false ->
                            NewState = State#state{children = proplists:delete(Proc_name, Children), permanent = Permanent},
                            io:format("Down process ~p with reason ~p ~n",[Pid, Reason])
                    end,
                    loop(NewState);
                false ->
                    loop(State)
            end
    end.

%%%%%% PRIVATE FUNCTIONS %%%%%%