%%%-------------------------------------------------------------------
%% @doc coursework2 top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(coursework2_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [],
    
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

    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
