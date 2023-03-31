-module(keylist).
-export([loop/1]).
-export([start/1, start_link/1, add/4, is_member/2, take/2, find/2, delete/2, stop/1]).

-record(state,{
    list = [] :: list,
    counter = 0 :: non_neg_integer
}).

-spec(start(Name :: atom()) -> 
    {Pid :: pid(), MonitorRef :: reference()}).
start(Name) ->
    {Pid, MonitorRef} = spawn_monitor(keylist, loop, [#state{}]),
    register(Name, Pid),
    {Pid, MonitorRef}.

-spec(start_link(Name :: atom()) ->
    Pid :: pid()).
start_link(Name) ->
    Pid = spawn_link(keylist, loop, [#state{}]),
    register(Name, Pid),
    Pid.

-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment :: atom() | string()) ->
    no_return()).
add(Name, Key, Value, Comment) -> 
    Name ! {self(), add, Key, Value, Comment}.

-spec(is_member(Name :: atom(), Key :: atom()| string()) ->
    no_return()).
is_member(Name, Key)->
    Name ! {self(), is_member, Key}.

-spec(take(Name :: atom(), Key :: atom()| string()) ->
    no_return()).
take(Name, Key)-> 
    Name ! {self(), take, Key}.

-spec(find(Name :: atom(), Key :: atom()| string()) ->
    no_return()).
find(Name, Key) -> 
    Name ! {self(), find, Key}.

-spec(delete(Name :: atom(), Key :: atom()| string()) ->
    no_return()).
delete(Name, Key)->
    Name ! {self(), delete, Key}.

-spec(stop(Name :: atom()) ->
    no_return()).
stop(Name)->
    Name ! stop.

-spec(loop(#state{list :: list(), counter :: non_neg_integer()}) ->
    no_return()).
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
            ok
        end.

%%%%%% PRIVATE FUNCTIONS %%%%%%