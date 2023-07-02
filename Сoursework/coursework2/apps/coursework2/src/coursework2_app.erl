%%%-------------------------------------------------------------------
%% @doc coursework public API
%% @end
%%%-------------------------------------------------------------------

-module(coursework2_app).

-behaviour(application).

-include_lib("../nksip/include/nksip.hrl").

-export([start/2, stop/1]).


start(_StartType, _StartArgs) ->
    coursework2_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
