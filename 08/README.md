# eltex_erlang_homework
Homework Erlang

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
