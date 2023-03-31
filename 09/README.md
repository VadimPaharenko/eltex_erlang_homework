# eltex_erlang_homework
Homework Erlang

Не очень понимаю, что конкретно нужно писать в выводе.

Я добавил API для вызова функций из модулей keylist_mgr и keylist, в выполнении команд это видно.
Поменял state для keylist_mgr, в permanent хранятся пиды процессов, которы нужно перезапустить при падении.

В keylist_mgr:loop при получении сообщения формата {'EXIT', Pid, Reason} через lists:member(Pid, Permanent) проверяется есть ли Pid завершенного процесса в списке для перезапуска.
Если он есть, процесс перезапускается, с обновлением даннных в state.children и state.permanent.

Решил, что процесс, который нужно перезапускать все таки можно завершить не аварийно, для этого нужно вызвать keylist_mgr:stop_child(Name), предполагается, что пользователь знает, что данный процесс является перезапускаемым, но все равно хочет его завершить без перезапуска, т.е. не аварийно.

Поменял действие keylist_mgr:stop_process, если вызывается данная функция процесс (король) keylist_mgr завершается и вызывает keylist:stop(Name) для всех своих дочерних процессов. В командах 16 - 18 это видно.

Так же написал тесты для keylist_mgr и keylist.

Вопросы: 

1. правильно ли написана спека, API функции ничего не возвращают, а передают сообщения процессу keylist_mgr, поэтому указал no_return(), но есть ощущение, что это не отражает реальность 

2. как писать документацию для функций, нужно ли писать ее для API функций и как написать доку для loop, стоит ли расписывать все кейсы входящих сообщений и все внутренние обработчики, кажется, что это гора текста, которая только мешает чтению кода.

*****************************************************************************************************************************************************

1> c(keylist).

{ok,keylist}

2> c(keylist_mgr).

{ok,keylist_mgr}

3> keylist_mgr:start().

{ok,<0.92.0>,#Ref<0.3184965755.3076521987.97065>}

4> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).

{<0.80.0>,start_child,
 #{name => keylist1,restart => temporary}}

5> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).

{<0.80.0>,start_child,
 #{name => keylist2,restart => permanent}}

6> keylist:add(keylist1, key1, “value1”, “comment1”).

{<0.80.0>,add,key1,"value1","comment1"}

7> flush().

Shell got {ok,<0.94.0>}
Shell got {ok,<0.96.0>}
Shell got {ok,{state,[{key1,"value1","comment1"}],1}}
ok

8> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).

{<0.80.0>,start_child,
 #{name => keylist3,restart => permanent}}

9> keylist_mgr:stop_child(keylist3).                                   

{<0.80.0>,stop_child,keylist3}

10> flush().

Shell got {ok,<0.100.0>}
Shell got {ok,{state,[{keylist2,<0.96.0>},{keylist1,<0.94.0>}],[<0.96.0>]}}
ok

11> whereis(keylist3). 

undefined

12> exit(whereis(keylist1), somereason).

true
Down process <0.94.0> with reason somereason

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

stop

19> whereis(keylist2).

undefined
