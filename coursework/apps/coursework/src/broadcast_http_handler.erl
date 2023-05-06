-module(broadcast_http_handler).
-export([init/2, broadcast/2]).

init(Req0, State)->
    Method = cowboy_req:method(Req0),
    Req = broadcast(Method, Req0),
    {ok, Req, State}.

broadcast(<<"GET">>, Req0)->
    odbc:start(),
    {ok, Ref} = odbc:connect("DSN=voth;UID=sa;PWD=sa", []),
    {selected, ["Phone"], List_data} = odbc:sql_query(Ref, "SELECT Phone FROM Abonents"),
    Data = [list_to_binary(Phone) || {Phone} <- List_data],
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'phones'=> Data}), Req0),
    ok;
broadcast(_, Req0)->
    cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'status'=> 404, 'error'=><<"Not Found">>}), Req0),
    ok.