# eltex_erlang_homework
Homework Erlang

В домашней работе создал процесс менеджер keylist_mgr, который управляет процессами модуля keylist.

Задание №2: по резульату выполнения команд (5 - 10) видно, что созданный keylist_mgr запускает новые процессы, процесс keylist3 обрабатывает входные данные и работает с ними через keylist:loop.

Задание №3.1

В loop проверяется вхождение сообщения вида {'EXIT', Pid, Reason}, после чего идет проверка, что переданный Pid является child процессом для keylist_mgr, если он при помощи lists:keyfind(Pid, 2, Children). Если Pid - child процесс, удаляем его из state и логируем io:format("Down process ~p with reason ~p ~n",[Pid, Reason]), если это не child процесс, логируем io:format("Process with Pid ~p undefined ~n",[Pid]) и идем в рекурсию с уже имевшимся state

flush() ничего не показывает, т.к. сообщение вида {'EXIT', From, Reason} уже было обработано через recive.

self() не меняется т.к. включен process_flag(trap_exit, true).

Задание №3.2

При завершении процесса keylist_mgr через exit, т.к. включен process_flag(trap_exit, true), сигнал завершения процесса преобразуется в сообщение формата {'EXIT', From, Reason}, т.е. сам процесс не завершается, получает сам в себя сообщение и обрабатывается через функцию loop.

flush() ничего не выводит и self() не меняется аналогично первому пункту.

Задание №3.3

Для завершения процесса приходится включать process_flag(trap_exit, false) при получении сообщения stop и закрывать процесс комадной exit, происходит завершение процесса, оно не преобразовывается в сообщение и все слинкованные с ним процессы так же завершаются (это видно в 21 и 22 командной строках).

Т.к. self() является монитором процесса keylist_mgr, flush() выводит сообщение вида {'DOWN', MonitorRef, Type, Object, Info}, сам он при этом не завершается т.к. не был слинкован с keylist_mgr.

*****************************************************************************************************************************************************

1> c(keylist_mgr).

{ok,keylist_mgr}

2> rr(keylist_mgr). 

[state]

3> c(keylist).

{ok,keylist}

4> self().

<0.80.0>

5> keylist_mgr:start().

{ok,<0.96.0>,#Ref<0.337467710.1923612679.2481>}

6> keylist_mgr ! {self(), start_child, keylist1}.

{<0.80.0>,start_child,keylist1}

7> keylist_mgr ! {self(), start_child, keylist2}.

{<0.80.0>,start_child,keylist2}

8> keylist_mgr ! {self(), start_child, keylist3}.

{<0.80.0>,start_child,keylist3}

9> keylist3 ! {self(), add, bob, 100, "man"}.

{<0.80.0>,add,bob,100,"man"}

10> flush().

Shell got {ok,<0.98.0>}
Shell got {ok,<0.100.0>}
Shell got {ok,<0.102.0>}
Shell got {ok,{state,[{bob,100,"man"}],1}}
ok

11> exit(whereis(keylist1), somereason).

Down process <0.98.0> with reason somereason 
true

12> flush().

ok

13> self().

<0.80.0>

14> exit(whereis(keylist_mgr), somereason).

Process with Pid <0.80.0> undefined 
true

15> flush().

ok

16> self().

<0.80.0>

17> keylist_mgr ! stop.

stop

18> flush().

Shell got {'DOWN',#Ref<0.337467710.1923612679.2481>,process,<0.96.0>,
                  stop_command}
ok

19> self().

<0.80.0>

20> whereis(keylist2).

undefined

21> whereis(keylist3).

undefined
