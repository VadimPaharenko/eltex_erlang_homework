-module(keylist_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1, stop_child/1]).

%% Callback
-export([init/1]).

%% API
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child(Name) ->
    supervisor:start_child(?MODULE, [Name]).

stop_child(Name) ->
    supervisor:terminate_child(?MODULE, whereis(Name)).

%% Callback
init(_Args) ->
    SupervisorSpecification = #{
        strategy => simple_one_for_one,
        intensity => 1,
        period => 5
    },

    ChildSpecifications = [
        #{
            id => keylist,
            start => {keylist, start_link, []},
            restart => permanent
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
