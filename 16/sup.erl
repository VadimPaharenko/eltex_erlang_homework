-module(sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Callback
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    SupervisorSpecification = #{
        strategy => one_for_one,
        intensity => 1,
        period => 5,
        auto_shutdown => any_significant
    },

    ChildSpecifications = [
        #{
            id => keylist_mgr,
            start => {keylist_mgr, start_monitor, []},
            restart => temporary,
            shutdown => brutal_kill,
            significant => true
        },
        #{
            id => keylist_sup,
            start => {keylist_sup, start_link, []},
            type => supervisor,
            shutdown => infinity
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
