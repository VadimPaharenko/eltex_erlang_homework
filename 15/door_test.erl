-module(door_test).
-include_lib("eunit/include/eunit.hrl").

-define(TEST_CODE, [1, 2, 3, 4]).

keylist_test_() ->
    {
        foreach, fun setup/0,
        [
            fun wrong_code_then_opened_then_alredy_open/0
        ]
    }.

setup() ->
    {ok, Pid}= door:start(?TEST_CODE),
    #{pid => Pid}.


wrong_code_then_opened_then_alredy_open() ->
    ?assertMatch({ok,next}, door:enter(1)),
    ?assertMatch({ok,next}, door:enter(2)),
    ?assertMatch({ok,next}, door:enter(3)),
    ?assertMatch({error, wrong_code, two_attempts_left}, door:enter(5)),
    ?assertMatch({ok,next}, door:enter(1)),
    ?assertMatch({ok,next}, door:enter(2)),
    ?assertMatch({ok,next}, door:enter(3)),
    ?assertMatch(opened, door:enter(4)),
    ?assertMatch({error, alredy_open}, door:enter(5)).