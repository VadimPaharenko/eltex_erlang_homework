%%%-------------------------------------------------------------------
%% @doc coursework public API
%% @end
%%%-------------------------------------------------------------------

-module(coursework_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/abonent", abonent_http_handler, []},
            {"/broadcast", broadcast_http_handler, []},
            {"/", coursework_http_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}}
    ),
    coursework_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
