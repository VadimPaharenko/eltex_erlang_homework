-module(database).

-include("abonents.hrl").

-export([start/0, get_abonents/0, get_abonent/1, add_abonent/1, delete_abonent/2]).

start() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(abonents, [{type, bag}, {attributes, record_info(fields, abonents)}]).

get_abonents() ->
    Fun = fun() ->
        mnesia:match_object({abonents, '_', '_'})
    end,
    mnesia:transaction(Fun).

get_abonent(Number) ->
    Fun = fun() ->
        mnesia:match_object({abonents, Number, '_'})
    end,
    mnesia:transaction(Fun).

add_abonent(Data) ->
    Fun = fun() ->
        mnesia:write(#abonents{num = maps:get(<<"num">>, Data), name = binary:bin_to_list(maps:get(<<"name">>, Data))})
    end,
    mnesia:transaction(Fun).

delete_abonent(Number, Name)->
    Fun = fun() ->
        mnesia:delete_object({abonents, Number, Name})
    end,
    mnesia:transaction(Fun).