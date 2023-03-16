-module(persons).
-include("person.hrl").
-export([any/2, all/2, filter/2, update/2, get_average_age/1]).

any(Pred, List)->
    case List of
            [] -> false;
            [Head | Tail] ->
                case Pred(Head) of
                    true -> true;
                    false -> any(Pred, Tail)
                end
        end.


all(Pred, List)->
    case List of
            [] -> true;
            [Head | Tail] ->
                case Pred(Head) of
                    true -> all(Pred,Tail);
                    false -> false
                end
        end.


filter(Pred,List) ->
    filter(Pred,List,[]).

filter(_,[],Acc)->
    lists:reverse(Acc);
filter(Pred,[Head|Tail],Acc)->
    case Pred(Head) of
        true -> filter(Pred,Tail,[Head|Acc]);
        false -> filter(Pred,Tail,Acc)
    end.


update(Pred,List)->
    update(Pred,List,[]).

update(_,[],Acc)->
    lists:reverse(Acc);
update(Pred,[Head|Tail],Acc)->
        update(Pred,Tail,[Pred(Head)|Acc]).



get_average_age(Persons) when is_list(Persons) ->
    case Persons of 
        []-> 0;
        [_Head|_Tail]->
            F = fun(#person{age=Age},{Acc1, Acc2}) ->
                {Age+Acc1, Acc2+1}
            end,
            {AgeSum, PersonsCount} = lists:foldl(F,{0,0},Persons),
            AgeSum/PersonsCount
    end.