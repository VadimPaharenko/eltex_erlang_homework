%% @doc module the module is designed to work with child generic server processes that are created by the keylist_mgr process.
-module(keylist).

-behaviour(gen_server).

-include("process_data.hrl").

%% API
-export([start_link/1, start_monitor/1, add/4, is_member/2, take/2, find/2, delete/2, match/2, match_object/2, select/2, stop/1]).

%% Callback
-export([init/1, handle_call/3, terminate/2, handle_info/2]).

-type(key() :: atom()).
-type(value() :: atom() | string()).
-type(comment() :: atom() | string()).
-record(state,{
    list = [] :: list({key(), value(), comment()}),
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
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment :: atom() | string()) -> ok).
add(Name, Key, Value, Comment) -> 
    gen_server:call(Name, {add, Key, Value, Comment}).

%% @doc API function synchronous call to the process of the generic server, sending '{is_member, Key}'
-spec(is_member(Name :: atom(), Key :: atom()| string()) -> true | false).
is_member(Name, Key)->
    gen_server:call(Name, {is_member, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{take, Key}'
-spec(take(Name :: atom(), Key :: atom()| string()) -> {process_data, atom(), atom() | string(), atom() | string()}  | false).
take(Name, Key) ->
    gen_server:call(Name, {take, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{find, Key}'
-spec(find(Name :: atom(), Key :: atom()| string()) -> {process_data, atom(), atom() | string(), atom() | string()}  | []).
find(Name, Key) ->
    gen_server:call(Name, {find, Key}).

%% @doc API function synchronous call to the process of the generic server, sending '{delete, Key}'
-spec(delete(Name :: atom(), Key :: atom()| string()) -> ok).
delete(Name, Key)->
    gen_server:call(Name, {delete, Key}).

-spec match(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match(Name, Pattern) ->
    gen_server:call(Name, {match, Pattern}).

-spec match_object(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match_object(Name, Pattern) ->
    gen_server:call(Name, {match_object, Pattern}).

-spec select(Name :: atom(), Filter :: fun()) -> {ok, list()}.
select(Name, Filter) ->
    gen_server:call(Name, {select, Filter}).

%% @doc API function for generic server stop process to exit with 'normal' reason
-spec(stop(Name :: atom()) ->
    ok).
stop(Name)->
    gen_server:stop(Name).


%% Callback
init(_Args) ->
    {ok, #state{}}.

handle_call({add, Key, Value, Comment}, _From, State) ->
    ets:insert(keylist_ets, #process_data{key = Key, value = Value, comment = Comment}),
    {reply, ok, State};
handle_call({is_member, Key}, _From, State) ->
    {reply, ets:member(keylist_ets, Key), State};
handle_call({take, Key}, _From, State) ->
    case ets:take(keylist_ets, Key) of
        [{process_data, FindKey, FindValue, FindComment}] -> 
            {reply, {process_data, FindKey, FindValue, FindComment}, State};
        [] ->
            {reply, false, State}
    end;
handle_call({find, Key}, _From, State) ->
    case ets:lookup(keylist_ets, Key) of
        [{process_data, FindKey, FindValue, FindComment}] -> 
            {reply, {process_data, FindKey, FindValue, FindComment}, State};
        [] ->
            {reply, [], State}
    end;
handle_call({delete, Key}, _From, State) ->
    ets:delete(keylist_ets, Key),
    {reply, ok, State};
handle_call({match, Pattern}, _From, State) ->
    {reply, {ok, ets:match(keylist_ets, Pattern)}, State};
handle_call({match_object, Pattern}, _From, State) ->
    {reply, {ok, ets:match_object(keylist_ets, Pattern)}, State};
handle_call({select, Filter}, _From, State) ->
    {reply, {ok, ets:select(keylist_ets, ets:fun2ms(Filter))}, State}.

handle_info({added_new_child, Pid, Name}, State) ->
    io:format("Aded_new process ~p with pid ~p~n",[Name, Pid]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.


%%%%%% PRIVATE FUNCTIONS %%%%%%
