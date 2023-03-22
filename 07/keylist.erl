-module(keylist).

-include("keylist.hrl").

-export([loop/1, start/1, start_link/1]).

loop(#state{list = List, counter = Counter} = State) when is_list(List), is_integer(Counter)->
    receive
        {From, add, Key, Value, Comment} -> 
            NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState);
        {From, is_member, Key} ->
            lists:keymember(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState);
        {From, take, Key} ->
            {_, _, TupleList} = lists:keytake(Key, 1, List),
            NewState = State#state{list = TupleList, counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState);
        {From, find, Key} ->
            lists:keyfind(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState);
        {From, delete, Key} ->
            NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState)
        end.


start(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
    register(Name, Pid),
    MonitorRef = monitor(process, Pid),
    {Pid, MonitorRef}.


start_link(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
    link(Pid),
    register(Name, Pid),
    Pid.