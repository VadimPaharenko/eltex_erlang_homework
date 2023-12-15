# eltex_erlang_homework
Homework Erlang

Использую public, ordered_set, named_table.
public - для того, чтобы обращаться к таблице из любого процесса.
ordered_set - для того, чтобы ключи были отсортированы по имени.

Правильно ли я понял, что в этой ДЗ - нужно было просто продемонстрировать работу с ETS и любой из процессов может создавать записи, которые никак не сопоставляются с процессом, который создал эту запись?

В следующей ДЗ можно релизовать весь тот же функционал, что было до этого со Statе, но использовать таблицу в которой будет храниться {name_proc, key, value, comment}? В таком формате мы можем отслеживать какой процесс создал запись и обновлять State или нужно использовать несколько ETS таблиц?

*************************************************************************************************************************************************
****

1> c(keylist_mgr).

{ok,keylist_mgr}

2> c(keylist).

{ok,keylist}

3> keylist_mgr:start_monitor().

{ok,{<0.94.0>,#Ref<0.833490521.2021654531.183158>}}

4> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).

{ok,<0.96.0>}

5> keylist:add(keylist1, key1, "value1", "comment1").

ok

6> keylist:is_member(keylist1, key2).

false

7> keylist:is_member(keylist1, key1).

true

8> keylist:take(keylist1, key2).

false

9> keylist:take(keylist1, key1).

{process_data,key1,"value1","comment1"}

10> keylist:add(keylist1, key1, "value1", "comment1").

ok

11> keylist:find(keylist1, key2).

[]

12> keylist:find(keylist1, key1).

{process_data,key1,"value1","comment1"}

13> keylist:delete(keylist1, key1). 

ok