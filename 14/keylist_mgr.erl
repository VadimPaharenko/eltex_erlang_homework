%% @doc module the module is designed to spawn_monitor new generic server processes, delete and restart them.
%% Processes and their parameters are stored in record state
-module(keylist_mgr).
-export([start_monitor/0, start_child/1, stop_child/1, get_names/0, stop_process/0]).%% API
-export([init/1, terminate/2, handle_call/3, handle_info/2]). %% Callback
-include("process_data.hrl").

-type(restart() :: permanent | temporary).
-record(state,{
    children = [] :: list({atom(), restart()}),
    permanent = [] :: list(pid())
}).


%% API
%% @doc API function for spawn and monitor generic server process
-spec(start_monitor() -> 
    {ok, {Pid :: pid(), MonitorRef :: reference()}}).
start_monitor() ->
    gen_server:start_monitor({local, ?MODULE}, ?MODULE, [], []).

%% @doc API function synchronous call to the process of the generic server, sending '{start_child, Params}'
-spec(start_child(Params :: #{name => atom(), restart => restart()}) ->
    {ok, pid()} | badarg).
start_child(#{name := _Proc_Name, restart := _Restart} = Params) ->
    gen_server:call(?MODULE, {start_child, Params});
start_child(_Params) ->
       badarg.

%% @doc API function synchronous call to the process of the generic server, sending '{stop_child, Name}'
-spec(stop_child(Name :: atom()) ->
    {ok, {state, list({atom(), restart()}), list(pid())}} | undefined).
stop_child(Name) ->
    gen_server:call(?MODULE, {stop_child, Name}).

%% @doc API function synchronous call to the process of the generic server, sending 'get_names'
-spec(get_names() ->
    {ok, {state, list({atom(), restart()}), list(pid())}}).
get_names() ->
    gen_server:call(?MODULE, get_names).

%% @doc API function for generic server stop keylist_mgr process to exit with 'normal' reason
-spec(stop_process() ->
    ok).
stop_process() ->
    gen_server:stop(?MODULE).

%% Callback
-spec(init(atom()) -> 
    no_return()).
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(keylist_ets, [public, ordered_set, named_table, {keypos, #process_data.key}]),
    {ok, #state{}}.

handle_call({start_child, #{name := Name, restart := Restart}}, _From, #state{children = Children, permanent = Permanent} = State) 
  when is_list(Children), is_list(Permanent), is_atom(Name), is_atom(Restart) ->
    case proplists:is_defined(Name, Children) of
        true ->
            {reply, {ok, process_is_alredy_started}, State};
        false ->
            {ok, Pid} = keylist:start_link(Name),
            case Restart of
                permanent ->
                    NewState = State#state{children = [{Name, Pid} | Children], permanent = [Pid | Permanent]};
                temporary ->
                    NewState = State#state{children = [{Name, Pid} | Children], permanent = Permanent}
            end,
            lists:foreach(fun({_, ChildPid}) -> ChildPid ! {added_new_child, Pid, Name} end,  Children),
            {reply, {ok, Pid}, NewState}
    end;
handle_call({stop_child, Name}, _From, #state{children = Children, permanent = Permanent} = State) 
  when is_list(Children), is_list(Permanent), is_atom(Name) ->
    case proplists:is_defined(Name, Children) of
        true ->
            keylist:stop(Name),
            NewState = State#state{children = proplists:delete(Name, Children), permanent = lists:delete(whereis(Name), Permanent)},
            {reply, {ok, NewState}, NewState};
        false ->
            {reply, undefined, State}
    end;
handle_call(get_names, _From, #state{children = Children, permanent = Permanent} = State) 
  when is_list(Children), is_list(Permanent) ->
    Proc_Names = proplists:get_keys(Children),
    {reply, {ok, Proc_Names}, State}.

handle_info({'EXIT', Pid, Reason}, #state{children = Children, permanent = Permanent} = State)
    when is_list(Children), is_list(Permanent), is_pid(Pid), is_atom(Reason) ->
      case lists:keyfind(Pid, 2, Children) of
        {Name, Pid} ->
            case lists:member(Pid, Permanent) of
                true ->
                    {ok, New_Pid} = keylist:start_link(Name),
                    NewState = State#state{children = lists:keyreplace(Name, 1, Children, {Name, New_Pid}), permanent = [New_Pid | lists:delete(Pid, Permanent)]},
                    io:format("Down process ~p with reason ~p, restarted with new pid ~p ~n",[Name, Reason, New_Pid]);
                false ->
                    NewState = State#state{children = proplists:delete(Name, Children), permanent = Permanent},
                    io:format("Down process ~p with reason ~p ~n",[Pid, Reason])
            end,
            {noreply, NewState};
        false ->
            {noreply, State}
    end.

-spec(terminate(atom(), #state{children :: list(), permanent :: list()}) -> 
    ok).
terminate(_Reason, #state{children = Children} = _State) ->
    lists:foreach(
                fun({Name, _Pid}) ->
                    keylist:stop(Name)
                end,
                Children),
                ok.

    
%%%%%% PRIVATE FUNCTIONS %%%%%%