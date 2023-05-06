%% @doc module the module is designed to work with child processes that are created by the keylist_mgr process.
-module(keylist).
-export([start/1, start_link/1, init/1, terminate/0]). %% API
-export([add/4, is_member/2, take/2, find/2, delete/2, stop/1]). %% API

-record(state,{
    list = [] :: list({atom() | string(),atom() | string(),atom() | string()}),
    counter = 0 :: non_neg_integer()
}).

%% @doc API function for spawn and link process
-spec(start_link(Name :: atom()) ->
    Pid :: pid()).
start_link(Name) ->
    spawn_link(keylist, init, [Name]).

%% @doc API function for register new process and start function loop(#state{}).
-spec(init(atom()) -> 
    no_return()).
init(Name) ->
    register(Name, self()),
    loop(#state{}).

%% @doc API function for spawn and monitor process
-spec(start(Name :: atom()) -> 
    {Pid :: pid(), MonitorRef :: reference()}).
start(Name) ->
    spawn_monitor(keylist, init, [Name]).

%% @doc API function for exit process
-spec(terminate() -> 
    ok).
terminate() ->
    ok.

%% @doc API function for send message {self(), add, Key, Value, Comment} to process
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment :: atom() | string()) ->
    ok).
add(Name, Key, Value, Comment) -> 
    Name ! {self(), add, Key, Value, Comment},
    ok.

%% @doc API function for send message {self(), is_member, Key} to process
-spec(is_member(Name :: atom(), Key :: atom()| string()) ->
    ok).
is_member(Name, Key)->
    Name ! {self(), is_member, Key},
    ok.

%% @doc API function for send message {self(), take, Key} to process
-spec(take(Name :: atom(), Key :: atom()| string()) ->
    ok).
take(Name, Key)-> 
    Name ! {self(), take, Key},
    ok.

%% @doc API function for send message {self(), find, Key} to process
-spec(find(Name :: atom(), Key :: atom()| string()) ->
    ok).
find(Name, Key) -> 
    Name ! {self(), find, Key},
    ok.

%% @doc API function for send message {self(), delete, Key} to process
-spec(delete(Name :: atom(), Key :: atom()| string()) ->
    ok).
delete(Name, Key)->
    Name ! {self(), delete, Key},
    ok.

%% @doc API function for send message stop to process
-spec(stop(Name :: atom()) ->
    ok).
stop(Name)->
    Name ! stop,
    ok.


%%%%%% PRIVATE FUNCTIONS %%%%%%


-spec(loop(#state{list :: list(), counter :: non_neg_integer()}) ->
    ok).
loop(#state{list = List, counter = Counter} = State) when is_list(List), is_integer(Counter)->
    receive
        {From, add, Key, Value, Comment} -> 
            NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
            From ! {ok, NewState},
            loop(NewState);
        {From, is_member, Key} ->
            Result = lists:keymember(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {Result, NewState},
            loop(NewState);
        {From, take, Key} ->
            {_, Tuple, TupleList} = lists:keytake(Key, 1, List),
            NewState = State#state{list = TupleList, counter = Counter + 1},
            From ! {Tuple, NewState},
            loop(NewState);
        {From, find, Key} ->
            Tuple = lists:keyfind(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {Tuple, NewState},
            loop(NewState);
        {From, delete, Key} ->
            NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
            From ! {ok, NewState},
            loop(NewState);
        stop ->
            keylist:terminate()
        end.