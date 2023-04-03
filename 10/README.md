# eltex_erlang_homework
Homework Erlang

Добавил функции init и terminate для keylist и keylist_mgr.

Добавил документацию для keylist, поменял spec для обоих модулей.

Немного поменял код, по комментариям из предыдущей работы и комментариям на лекциях.

Тесты для keylist были написаны в предыдущей работе.

*****************************************************************************************************************************************************

1> c(keylist).

{ok,keylist}

2> c(keylist_mgr).

{ok,keylist_mgr}

3> keylist_mgr:start().

{ok,<0.92.0>,#Ref<0.305497799.4247781382.233664>}

4> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).

ok

5> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).

ok

6> keylist:add(keylist1, key1, “value1”, “comment1”).

ok

7> flush().

Shell got {ok,<0.94.0>}
Shell got {ok,<0.96.0>}
Shell got {ok,{state,[{key1,"value1","comment1"}],1}}
ok

8> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).

ok

9> keylist_mgr:stop_child(keylist3).                                   

ok

10> flush().

Shell got {ok,<0.100.0>}
Shell got {ok,{state,[{keylist2,<0.96.0>},{keylist1,<0.94.0>}],[<0.96.0>]}}
ok

11> whereis(keylist3). 

undefined

12> exit(whereis(keylist1), somereason).

Down process <0.94.0> with reason somereason
true

13> whereis(keylist1).

undefined

14> exit(whereis(keylist2), somereason).

Down process keylist2 with reason somereason, restarted with new pid <0.107.0> 
true

15> whereis(keylist2).

<0.107.0>

16> exit(whereis(keylist2), somereason).

Down process keylist2 with reason somereason, restarted with new pid <0.110.0> 
true

17> whereis(keylist2).

<0.110.0>

18> keylist_mgr:stop_process().

ok

19> whereis(keylist2).

undefined

*****************************************************************************************************************************************************

1> c(keylist_test).                                     

{ok,keylist_test}

2> eunit:test(keylist_test).

  Test passed.
ok

*****************************************************************************************************************************************************

1> c(keylist_mgr_test).

{ok,keylist_mgr_test}

2> eunit:test(keylist_mgr_test).

  2 tests passed.
ok
