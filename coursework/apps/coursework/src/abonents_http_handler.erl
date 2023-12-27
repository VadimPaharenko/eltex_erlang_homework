-module(abonents_http_handler).

-export([init/2, abonents/2]).

-include("abonents.hrl").

init(Req0, State)->
    Method = cowboy_req:method(Req0),
    Req = abonents(Method, Req0),
    {ok, Req, State}.

abonents(<<"GET">>, Req0)->
    Fun = fun() -> 
        Data = mnesia:match_object({abonents, '_', '_'}),
        Nums = [Num || {abonents, Num, _} <- Data],
        Names = [list_to_binary(Name) || {abonents, _, Name} <- Data],
        cowboy_req:reply(200, #{
            <<"content-type">> => <<"application/json">>
        }, jsone:encode(#{'names'=> Names, 'nums'=> Nums}), Req0)
    end,
    mnesia:transaction(Fun),
    ok;
abonents(_, Req0)->
    cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, Req0),
    ok.