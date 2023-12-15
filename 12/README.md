# eltex_erlang_homework
Homework Erlang

Реализовал модули keylist и keylist_mgr используя архитектуру gen_server, обновил doc и spec для API функций.

Для отправки реквестов использовал gen_server:call для того, чтобы видеть результат выполнения команд в консоли.

Вопросов по работе нет, какие выводы писать не знаю)
Т.к. функционал программы почти не изменился, но был реализован новыми методами

*************************************************************************************************************************************************
****

1> c(keylist).

{ok,keylist}

2> c(keylist_mgr). 

{ok,keylist_mgr}

3> keylist_mgr:start_monitor().

{ok,{<0.92.0>,#Ref<0.3820437015.1251213327.210906>}}

4> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).

{ok,<0.94.0>}

5> keylist:add(keylist1, key1, "value1", "comment1").                   

{ok,{state,[{key1,"value1","comment1"}],1}}

6> keylist:is_member(keylist1, key1).                       

{true,{state,[{key1,"value1","comment1"}],2}}

7> keylist:take(keylist1, key1).      

{{key1,"value1","comment1"},{state,[],3}}

8> keylist:add(keylist1, key1, "value1", "comment1").

{ok,{state,[{key1,"value1","comment1"}],4}}

9> keylist:find(keylist1, key1). 

{{key1,"value1","comment1"},
 {state,[{key1,"value1","comment1"}],5}}

10> keylist:delete(keylist1, key1). 

{ok,{state,[],6}}

11> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).

Aded_new process keylist2 with pid <0.102.0>
{ok,<0.102.0>}

12> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).

Aded_new process keylist3 with pid <0.104.0>
Aded_new process keylist3 with pid <0.104.0>
{ok,<0.104.0>}

13> keylist_mgr:stop_child(keylist3).

{ok,{state,[{keylist2,<0.102.0>},{keylist1,<0.94.0>}],
           [<0.104.0>,<0.102.0>]}}

14> whereis(keylist3).

undefined

15> exit(whereis(keylist1), somereason).

Down process <0.94.0> with reason somereason 
true

16> whereis(keylist1).

undefined

17> keylist:stop(keylist2).

Down process keylist2 with reason normal, restarted with new pid <0.110.0> 
ok

18> whereis(keylist2).

<0.110.0>

19> exit(whereis(keylist2), somereason). 

Down process keylist2 with reason somereason, restarted with new pid <0.113.0> 
true

20> whereis(keylist2).

<0.113.0>

21> keylist_mgr:get_names().    

{ok,[keylist2]}

22> keylist_mgr:stop_process().

ok

23> whereis(keylist2).          

undefined