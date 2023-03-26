# eltex_erlang_homework
Homework Erlang

В домашней работе создал процесс менеджер keylist_mgr, который управляет процессами модуля keylist.

Задание №2: по резульату выполнения команд (5 - 10) видно, что созданный keylist_mgr запускает новые процессы, процесс keylist3 обрабатывает входные данные и работает с ними через keylist:loop.

Задание №3.1

Не очень понимаю каким образом нужно логировать падение процесса, т.к. процесс keylist_mgr не является монитором процессов keylis1, keylis2, keylis3 сообщение вида {'DOWN', MonitorRef, Type, Object, Info} мы не получаем. Не ясно, почему не отправляются ссобщения через ! ни в один из процессов, хотя видно, что в это условие функции мы попадаем, вывожу это через io:format (11 командная строка).

flush() ничего не показывает, т.к. сообщение вида {'EXIT', From, Reason} уже было обработано через recive.

self() не меняется т.к. включен process_flag(trap_exit, true).

Задание №3.2

При завершении процесса keylist_mgr через exit, т.к. включен process_flag(trap_exit, true), сигнал завершения процесса преобразуется в сообщение формата {'EXIT', From, Reason}, т.е. сам процесс не завершается, получает сам в себя сообщение и обрабатывается через функцию loop.

flush() ничего не выводит и self() не меняется аналогично первому пункту.

Задание №3.3

Для завершения процесса приходится включать process_flag(trap_exit, false), происходит завершение процесса, оно не преобразовывается в сообщение и все слинкованные с ним процессы так же завершаются (это видно в 20 и 21 командной строках).

Т.к. self() является монитором процесса keylist_mgr, flush() выводит сообщение вида {'DOWN', MonitorRef, Type, Object, Info}, сам он при этом не завершается т.к. не был слинкован с keylist_mgr.

*****************************************************************************************************************************************************

1> rr("keylist_mgr.hrl").

[state]

2> c(keylist_mgr).     

{ok,keylist_mgr}

3> c(keylist).     

{ok,keylist}

4> self().

<0.80.0>

5> keylist_mgr:start().

{ok,<0.98.0>,#Ref<0.2306717535.1909981194.22116>}

6> keylist_mgr ! {self(), start_child, keylist1}.

{<0.80.0>,start_child,keylist1}

7> keylist_mgr ! {self(), start_child, keylist2}.

{<0.80.0>,start_child,keylist2}

8> keylist_mgr ! {self(), start_child, keylist3}.

{<0.80.0>,start_child,keylist3}

9> keylist3 ! {self(), add, bob, 100, "man"}.

{<0.80.0>,add,bob,100,"man"}

10> flush().                                       

Shell got {ok,<0.100.0>}
Shell got {ok,<0.102.0>}
Shell got {ok,<0.104.0>}
Shell got {ok,{state,[{bob,100,"man"}],1}}
ok

11> exit(whereis(keylist1), somereason). 

Down process <0.100.0> with reason somereason 
true

12> flush().

ok

13> self().

<0.80.0>

14> exit(whereis(keylist_mgr), somereason). 

true

15> flush().

ok

16> self().

<0.80.0>

17> keylist_mgr ! stop.

stop

18> flush().

Shell got {'DOWN',#Ref<0.2306717535.1909981194.22116>,process,<0.98.0>,
                  stop_command}
ok

19> self().

<0.80.0>

20> whereis(keylist2).                             

undefined

21> whereis(keylist3). 

undefined