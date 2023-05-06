-module(coursework_http_handler).
-export([init/2]).

init(Req0, State)->
    Req = cowboy_req:reply(404, #{
        <<"content-type">> => <<"application/json">>
    }, jsone:encode(#{'status'=> 404, 'error'=><<"Not Found">>}), Req0),
    {ok, Req, State}.