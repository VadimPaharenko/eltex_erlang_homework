%% @doc module the module is designed to work with child generic server processes that are created by the keylist_mgr process.
-module(keylist).
-export([start_link/1, start_monitor/1, add/4, is_member/2, take/2, find/2, delete/2, stop/1]). %% API
-export([init/1, handle_call/3, terminate/2, handle_info/2]). %% Callback

-record(state,{
    list = [] :: list({atom(), atom() | string(), atom() | string()}),
    counter = 0 :: non_neg_integer()
}).

%% API
%% @doc API function for spawn and link generic server process
-spec(start_link(Name :: atom()) ->
    {ok, pid()}).
start_link(Name) when is_atom(Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [], []).

%% @doc API function for spawn and monitor generic server process
-spec(start_monitor(Name :: atom()) -> 
    {ok, {pid(), reference()}}).
start_monitor(Name) when is_atom(Name) ->
    gen_server:start_monitor({local, Name}, ?MODULE, [], []).

%% @doc API function synchronous call to the process of the generic server, sending '{add, Key, Value, Comment}'
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment :: atom() | string()) ->
    {ok, {state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}).
add(Name, Key, Value, Comment) -> 
    gen_server:call(Name, {add, Key, Value, Comment}).

%% @doc API function synchronous call to the process of the generic server, sending '{is_member, Key}'
-spec(is_member(Name :: atom(), Key :: atom()| string()) ->
    {true,{state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}|
    {false,{state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}).
is_member(Name, Key)->
    gen_server:call(Name, {is_member, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{take, Key}'
-spec(take(Name :: atom(), Key :: atom()| string()) ->
    {{atom(), atom() | string(), atom() | string()}, {state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}} | false).
take(Name, Key) ->
    gen_server:call(Name, {take, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{find, Key}'
-spec(find(Name :: atom(), Key :: atom()| string()) ->
    {{atom(), atom() | string(), atom() | string()}, {state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}|
    {false, {state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}).
find(Name, Key) ->
    gen_server:call(Name, {find, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{delete, Key}'
-spec(delete(Name :: atom(), Key :: atom()| string()) ->
    {ok, {state, list({atom(), atom() | string(), atom() | string()}), non_neg_integer()}}).
delete(Name, Key)->
    gen_server:call(Name, {delete, Key}).

%% @doc API function for generic server stop process to exit with 'normal' reason
-spec(stop(Name :: atom()) ->
    ok).
stop(Name)->
    gen_server:stop(Name).

%% Callback
-spec(init(atom()) -> 
    no_return()).
init(_Args) ->
    {ok, #state{}}.

handle_call({add, Key, Value, Comment}, _From, #state{list = List, counter = Counter} = State) ->
    NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
    {reply, {ok, NewState}, NewState};
handle_call({is_member, Key}, _From, #state{list = List, counter = Counter} = State) ->
    Result = lists:keymember(Key, 1, List),
    NewState = State#state{counter = Counter + 1},
    {reply, {Result, NewState}, NewState};
handle_call({take, Key}, _From, #state{list = List, counter = Counter} = State) ->
    case lists:keytake(Key, 1, List) of
        {_, Tuple, TupleList} -> 
            NewState = State#state{list = TupleList, counter = Counter + 1},
            {reply, {Tuple, NewState}, NewState};
        false ->
            {reply, false, State}
    end;
handle_call({find, Key}, _From, #state{list = List, counter = Counter} = State) ->
    Tuple = lists:keyfind(Key, 1, List),
    NewState = State#state{counter = Counter + 1},
    {reply, {Tuple, NewState}, NewState};
handle_call({delete, Key}, _From, #state{list = List, counter = Counter} = State) ->
    NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
    {reply, {ok, NewState}, NewState};
handle_call(stop, _From, State) ->
    {stop, normal, State}.

-spec(terminate(atom(), atom()) -> 
    ok).
terminate(_Reason, _State) ->
    ok.

handle_info({added_new_child, Pid, Name}, State) ->
    io:format("Aded_new process ~p with pid ~p~n",[Name, Pid]),
    {noreply, State}.

%%%%%% PRIVATE FUNCTIONS %%%%%%
