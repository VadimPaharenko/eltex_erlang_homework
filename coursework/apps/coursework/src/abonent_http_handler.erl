-module(abonent_http_handler).

-export([init/2, abonent/3]).

-include("abonents.hrl").

init(Req0, State)->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Req = abonent(Method, HasBody, Req0),
    {ok, Req, State}.
        

abonent(<<"GET">>, _, Req0)->
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
            Fun = fun() ->
                try
                    list_to_integer(binary:bin_to_list(Bin_Number)),
                    List_data = mnesia:match_object({abonents, list_to_integer(binary:bin_to_list(Bin_Number)), '_'}),
                        case List_data of
                            [] ->
                            cowboy_req:reply(200, #{
                                <<"content-type">> => <<"application/json">>
                            }, jsone:encode(#{'name'=> [], 'phone'=> []}), Req0);
                            _ ->
                                [{abonents, Number, Name}] = List_data,
                                cowboy_req:reply(200, #{
                                    <<"content-type">> => <<"application/json">>
                                }, jsone:encode(#{'name'=> binary:list_to_bin(string:strip(Name)), 'num'=> Number}), Req0)
                        end
                catch error:badarg ->
                    cowboy_req:reply(400, #{
                            <<"content-type">> => <<"application/json">>
                        }, jsone:encode(#{'error'=>{
                        [{<<"fields">>,
                            [{<<"Key">>, <<"num">>},{<<"Value">>, <<"Please enter abonent's number in integer format">>}]
                        }]
                        }, 'title'=><<"Validation error">>}), Req0)
                end
            end,
            mnesia:transaction(Fun);
        _ ->
            cowboy_req:reply(400, #{
                <<"content-type">> => <<"application/json">>
            }, jsone:encode(#{'error'=>{
                [{<<"fields">>,
                    [{<<"Key">>, <<"number">>},{<<"Value">>, <<"Please enter phone number">>}]
                }]
            }, 'title'=><<"Validation error">>}), Req0)
    end,
    ok;

abonent(<<"POST">>, true, Req0)->
    {ok, DataBin, _Req} = cowboy_req:read_body(Req0),
    DataDecoded = jsone:decode(DataBin),
    case DataDecoded of
        #{<<"name">> := _,<<"num">> := _} -> 
            Fun = fun() ->
                mnesia:write(#abonents{num = maps:get(<<"num">>, DataDecoded), name = binary:bin_to_list(maps:get(<<"name">>, DataDecoded))})
            end,
            mnesia:transaction(Fun),
            cowboy_req:reply(200, #{
                <<"content-type">> => <<"application/json">>
            }, jsone:encode(#{'result'=><<"Abonent added">>}), Req0);
        _ -> 
            cowboy_req:reply(400, #{
                <<"content-type">> => <<"application/json">>
            }, jsone:encode(#{'error'=>{
                [{<<"fields">>,
                    [{<<"Keys">>, <<"num, name">>},{<<"Value">>, <<"Please enter abonent's number and name">>}]
                }]
            }, 'title'=><<"Validation error">>}), Req0)
    end,
    ok;

abonent(<<"DELETE">>, _, Req0)->
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
        Fun = fun() ->
                try
                    list_to_integer(binary:bin_to_list(Bin_Number)),
                    List_data = mnesia:match_object({abonents, list_to_integer(binary:bin_to_list(Bin_Number)), '_'}),
                        case List_data of
                            [] ->
                            cowboy_req:reply(200, #{
                                <<"content-type">> => <<"application/json">>
                            }, jsone:encode(#{'result'=><<"Abonent not found">>}), Req0);
                        _ ->
                            [{abonents, Number, Name}] = List_data,
                            mnesia:delete_object({abonents, Number, Name}),
                            cowboy_req:reply(200, #{
                                <<"content-type">> => <<"application/json">>
                            }, jsone:encode(#{'result'=><<"Abonent deleted">>}), Req0)
                        end
                catch error:badarg ->
                    cowboy_req:reply(400, #{
                            <<"content-type">> => <<"application/json">>
                        }, jsone:encode(#{'error'=>{
                        [{<<"fields">>,
                            [{<<"Key">>, <<"num">>},{<<"Value">>, <<"Please enter abonent's number in integer format">>}]
                        }]
                        }, 'title'=><<"Validation error">>}), Req0)
                end
            end,
            mnesia:transaction(Fun);
    _ ->
            cowboy_req:reply(400, #{
                <<"content-type">> => <<"application/json">>
            }, jsone:encode(#{'error'=>{
                [{<<"fields">>,
                    [{<<"Key">>, <<"number">>},{<<"Value">>, <<"Please enter phone number">>}]
                }]
            }, 'title'=><<"Validation error">>}), Req0)
    end,
    ok;

abonent(_, _, Req0)->
    cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, Req0),
    ok.