%% @doc module the module is designed to spawn_monitor new processes, delete and restart them.
%% Processes and their parameters are stored in record state
-module(keylist_mgr).
-export([init/0, start/0, terminate/1]). %% API
-export([start_child/1, stop_child/1, stop_process/0, get_names/0]).%% API

-type(restart() :: permanent | temporary).
-record(state,{
    children = [] :: list({atom(), restart()}),
    permanent = [] :: list(pid())
}).

%% @doc API function for register new process, start function loop(#state{}) and start process_flag(trap_exit, true).
-spec(init() -> 
    no_return()).
init() ->
    process_flag(trap_exit, true),
    register(?MODULE, self()),
    loop(#state{}).

%% @doc API function for spawn_monitor process
-spec(start() -> 
    {ok, Pid :: pid(), MonitorRef :: reference()}).
start() ->
    {Pid, MonitorRef} = spawn_monitor(?MODULE, init, []),
    {ok, Pid, MonitorRef}.

%% @doc API function for stop process ?MODULE and stop all child processes
-spec(terminate(#state{children :: list(), permanent :: list()}) -> 
    ok).
terminate(#state{children = Children} = State) ->
    lists:foreach(
                fun({Name, _Pid}) ->
                    keylist:stop(Name)
                end,
                Children),
                ok.


%% @doc API function for send message {self(), start_child, Params when Params :: #{name => atom(), restart => restart()}}
%% to keylist_mgr process.
-spec(start_child(Params :: #{name => atom(), restart => restart()}) ->
    ok | badarg).
start_child(#{name := _Proc_Name , restart := _Restart} = Params) ->
        keylist_mgr ! {self(), start_child, Params},
        ok;
start_child(_Params) ->
       badarg.

%% @doc API function for send message {self(), stop_child, Name} to keylist_mgr process
-spec(stop_child(Name :: atom()) ->
    ok).
stop_child(Name) ->
    keylist_mgr ! {self(), stop_child, Name},
    ok.

%% @doc API function for send message stop to keylist_mgr process
-spec(stop_process() ->
    ok).
stop_process() ->
    keylist_mgr ! stop,
    ok.

%% @doc API function for send message {self(), get_names} to keylist_mgr process
-spec(get_names() ->
    ok).
get_names() ->
    keylist_mgr ! {self(), get_names},
    ok.


%%%%%% PRIVATE FUNCTIONS %%%%%%


-spec(loop(#state{children :: list(), permanent :: list()}) ->
    string() | ok).
loop(#state{children = Children, permanent = Permanent} = State) when is_list(Children), is_list(Permanent) ->
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
                    keylist:stop(Name),
                    NewState = State#state{children = proplists:delete(Name, Children), permanent = lists:delete(whereis(Name), Permanent)},
                    From ! {ok, NewState},
                    loop(NewState);
                false ->
                    From ! undefined,
                    loop(State)
            end;
        stop ->
            keylist_mgr:terminate(State);
        {From, get_names} ->
            Proc_Names = proplists:get_keys(Children),
            From ! lists:reverse(Proc_Names),
            loop(State);
        {'EXIT', Pid, Reason} ->
            case lists:keyfind(Pid, 2, Children) of
                {Name, Pid} -> 
                    case lists:member(Pid, Permanent) of
                        true ->
                            New_Pid = keylist:start_link(Name),
                            NewState = State#state{children = lists:keyreplace(Name, 1, Children, {Name, New_Pid}),
                                permanent = [New_Pid | lists:delete(Pid, Permanent)]},
                            io:format("Down process ~p with reason ~p, restarted with new pid ~p ~n",[Name, Reason, New_Pid]);
                        false ->
                            NewState = State#state{children = proplists:delete(Name, Children), permanent = Permanent},
                            io:format("Down process ~p with reason ~p ~n",[Pid, Reason])
                    end,
                    loop(NewState);
                false ->
                    loop(State)
            end
    end.