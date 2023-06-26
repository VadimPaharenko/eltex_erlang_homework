%%%-------------------------------------------------------------------
%% @doc coursework public API
%% @end
%%%-------------------------------------------------------------------

-module(coursework2_app).

-behaviour(application).

-include_lib("../nksip/include/nksip.hrl").

-export([start/2, stop/1]).


start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/abonent", abonent_http_handler, []},
            {"/abonents", abonents_http_handler, []},
            {"/call", call_http_handler, []},
            {"/", coursework_http_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}}
    ),

    dialer:start(),
    database:start(),
    coursework2_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
