-module(recursion).
-export([tail_fac/1, duplicate/1, tail_duplicate/1]).

tail_fac(N) when is_integer(N)->
    tail_fac(N,1);
tail_fac(Error) ->
    io:format("Error arg ~p~n",[Error]),
    {error, badarg}.

tail_fac(0,Acc)->
    Acc;
tail_fac(N,Acc) when is_integer(N)->
    tail_fac(N-1,N*Acc).


duplicate([Head|Tail])->
    [Head,Head|duplicate(Tail)];
duplicate([])->
    [];
duplicate(Error) ->
    io:format("Error arg ~p~n",[Error]),
    {error, badarg}.

tail_duplicate([Head|Tail])->
    tail_duplicate([Head|Tail],[]);
tail_duplicate([])->
    [];
tail_duplicate(Error) ->
    io:format("Error arg ~p~n",[Error]),
    {error, badarg}.

tail_duplicate([],Acc)->
    lists:reverse(Acc);
tail_duplicate([Head|Tail],Acc)->
    tail_duplicate(Tail,[Head,Head|Acc]).
