-module(keylist_test).
-include_lib("eunit/include/eunit.hrl").

-define(TEST_KEYLIST_NAME, keylist1).
-define(TEST_KEY, "test_key").
-define(TEST_VALUE, "test_value").
-define(TEST_COMMENT, "test_comment").

keylist_test_() ->
    {
        foreach, fun setup/0, fun teardown/1,
        [
            fun test_add_find_member_take_delete/0
        ]
    }.

setup() ->
    Pid = keylist:start_link(?TEST_KEYLIST_NAME),
    #{pid => Pid, name => ?TEST_KEYLIST_NAME}.


test_add_find_member_take_delete() ->
    TestKey = "test_key",
    TestValue = "test_value",
    TestComment = "test_comment",
    keylist:add(?TEST_KEYLIST_NAME, TestKey, TestValue, TestComment),
    ?assertMatch({ok, {state, [{TestKey, TestValue, TestComment}], 1}}, wait_result()),
    keylist:find(?TEST_KEYLIST_NAME, TestKey),
    ?assertMatch({{TestKey, TestValue, TestComment}, {state, [{TestKey, TestValue, TestComment}], 2}}, wait_result()),
    keylist:is_member(?TEST_KEYLIST_NAME, TestKey),
    ?assertMatch({true, {state, [{TestKey, TestValue, TestComment}], 3}}, wait_result()),
    keylist:take(?TEST_KEYLIST_NAME, TestKey),
    ?assertMatch({{TestKey, TestValue, TestComment}, {state, [], 4}}, wait_result()),
    keylist:add(?TEST_KEYLIST_NAME, TestKey, TestValue, TestComment),
    ?assertMatch({ok, {state, [{TestKey, TestValue, TestComment}], 5}}, wait_result()),
    keylist:delete(?TEST_KEYLIST_NAME, TestKey),
    ?assertMatch({ok, {state, [], 6}}, wait_result()).

teardown(#{pid := Pid, name := Name}) ->
    erlang:monitor(process, Pid),
    keylist:stop(Name),
    receive
        {'DOWN', _Ref, process, _Pid, _Reason} ->
            ok
    end.


wait_result() ->
    receive
        Msg -> Msg
    end.