-module(abonent_http_handler).
-export([init/2, abonent/2]).

init(Req0, State)->
    Method = cowboy_req:method(Req0),
    Req = abonent(Method, Req0),
    {ok, Req, State}.
        

abonent(<<"GET">>, Req0)->
    odbc:start(),
    {ok, Ref} = odbc:connect("DSN=voth;UID=sa;PWD=sa", []),
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
            SQLQuery = "SELECT * FROM Abonents WHERE Phone = " ++ binary:bin_to_list(Bin_Number),
            {selected, ["Name","Phone"], List_data} = odbc:sql_query(Ref, SQLQuery),
            case List_data of 
                [] ->
                    cowboy_req:reply(200, #{
                        <<"content-type">> => <<"application/json">>
                    }, jsone:encode(#{'name'=> [], 'phone'=> []}), Req0);
                _ ->
                    [{Name, Phone}] = List_data,
                    cowboy_req:reply(200, #{
                        <<"content-type">> => <<"application/json">>
                    }, jsone:encode(#{'name'=> binary:list_to_bin(string:strip(Name)), 'phone'=> binary:list_to_bin(Phone)}), Req0)
                end,
        ok;
        _ ->
            cowboy_req:reply(200, #{
                <<"content-type">> => <<"application/json">>
            }, jsone:encode(#{'error'=>{
                [{<<"fields">>,
                    [{<<"Key">>, <<"number">>},{<<"Value">>, <<"Please enter phone number">>}]
                }]
            }, 'title'=><<"Validation error">>, 'status'=> 400}), Req0)
        end,
    ok;
abonent(_, Req0)->
    cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'status'=> 404, 'error'=><<"Not Found">>}), Req0),
    ok.