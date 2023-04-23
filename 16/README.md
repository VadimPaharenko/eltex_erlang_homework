# eltex_erlang_homework
Homework Erlang

Я добавил 2 супервизора для keylist и keylist_mgr, есть несколько вопросов.

1. Зачем нам вообще нужен keylist_mgr в этой схеме, он не запускает процессы и поэтому не мониторит их, за это теперь отвечает keylist_sup, непонятно каким образом его вообще использовать.

2. Не знаю, правильно ли настроены параменты для супервизоров, хотел сделать по аналогии с keylist_mgr (отвечает за все созданные процессы, перезапускает и если он завершается, то все созданные процессы должны завершиться).

3. Не понятно, почему мой супервизор sup не завершается, когда я завершаю keylist_mgr, командой keylist_mgr:stop_process(), хотя в sup настроено restart => temporary, significant => true и auto_shutdown => any_significant

*************************************************************************************************************************************************
****

1> c(sup).                              

{ok,sup}

2> c(keylist_sup).                      

{ok,keylist_sup}

3> c(keylist_mgr).                      

keylist_mgr.erl:5:2: Warning: undefined callback function handle_cast/2 (behaviour 'gen_server')
%    5| -behaviour(gen_server).
%     |  ^
{ok,keylist_mgr}

4> c(keylist).                          

keylist.erl:4:2: Warning: undefined callback function handle_cast/2 (behaviour 'gen_server')
%    4| -behaviour(gen_server).
%     |  ^
{ok,keylist}

5> sup:start_link().                    

{ok,<0.104.0>}

6> keylist_sup:start_child(keylist1).   

{ok,<0.108.0>}

7> exit(whereis(keylist1), somereason).

true

=SUPERVISOR REPORT==== 23-Apr-2023::23:19:40.764000 ===
    supervisor: {local,keylist_sup}
    errorContext: child_terminated
    reason: somereason
    offender: [{pid,<0.108.0>},
               {id,keylist},
               {mfargs,{keylist,start_link,[keylist1]}},
               {restart_type,permanent},
               {significant,false},
               {shutdown,5000},
               {child_type,worker}]

8> whereis(keylist1).                   

<0.110.0>

9> keylist_sup:stop_child(keylist1).    

ok

10> whereis(keylist1).

undefined

11> whereis(keylist_mgr).                

<0.105.0>

12> keylist_mgr:stop_process().

ok

13> =ERROR REPORT==== 23-Apr-2023::23:20:34.463000 ===
Supervisor received unexpected message: {'DOWN',
                                         #Ref<0.3526045325.3888381960.261805>,
                                         process,<0.105.0>,normal}

13> whereis(sup).

<0.104.0>