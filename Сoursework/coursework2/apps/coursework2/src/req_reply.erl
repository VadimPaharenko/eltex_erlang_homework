-module(req_reply).

-export([reply_abonents_data/3, reply_abonent_data/2, reply_result/2, reply_error/3, reply_404/1]).

reply_abonents_data(Names, Nums, Req0) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'names'=> Names, 'nums'=> Nums}), Req0).


reply_abonent_data([], Req0) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'name'=> [], 'num'=> []}), Req0);

reply_abonent_data([{abonents, Number, Name}], Req0) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'name'=> binary:list_to_bin(string:strip(Name)), 'num'=> Number}), Req0).


reply_result(Result, Req0) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'result'=>Result}), Req0).


reply_error(<<"num, name">>, Value, Req0) ->
    cowboy_req:reply(400, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'error'=>{
            [{<<"fields">>,
                [{<<"Keys">>, <<"num, name">>},{<<"Value">>, Value}]
            }]
        }, 'title'=><<"Validation error">>}), Req0);

reply_error(Key, Value, Req0) ->
    cowboy_req:reply(400, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'error'=>{
            [{<<"fields">>,
                [{<<"Key">>, Key},{<<"Value">>, Value}]
            }]
        }, 'title'=><<"Validation error">>}), Req0).


reply_404(Req0) ->
    cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'status'=> 404, 'error'=><<"Not Found">>}), Req0).