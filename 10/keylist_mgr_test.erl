-module(keylist_mgr_test).
-include_lib("eunit/include/eunit.hrl").

-define(TEST_PROCESS_NAME, keylist1).
-define(TEST_PARAMETR, temporary).
-define(TEST_REASON, somereason).

keylist_mgr_test_() ->
    {
        setup, fun setup/0,
        [
            fun test_get_names/0,
            fun test_stop_child/0
        ]
    }.

setup() ->
    {ok, Pid, MonitorRef} = keylist_mgr:start(),
    #{pid => Pid, ref => MonitorRef}.

test_get_names() ->
    keylist_mgr:start_child(#{name => ?TEST_PROCESS_NAME, restart => ?TEST_PARAMETR}),
    ?assertMatch({ok, _Pid}, wait_result()),
    keylist_mgr:get_names(),
    ?assertMatch([?TEST_PROCESS_NAME], wait_result()).

test_stop_child() ->
    keylist_mgr:stop_child(?TEST_PROCESS_NAME),
    ?assertMatch({ok, {state , [], []}}, wait_result()).


wait_result() ->
    receive
        Msg -> Msg
    end.

