# eltex_erlang_homework
Homework Erlang
В этой домашней работе я поработал с функциями rec_to_rub/1 и map_to_rub/1, которые принимают на вход тип данных record и map соответственно. Я научился использовать pattern matching для подобного рода функций.

Так же я написал несколько рекурсивных функций, попрактиковался в написании функций с обычной и хвостовой рекурсиями. Например, 2 функции с одинаковым функционалом дублирования элементов списка.

Еще на практике узнал как пользоваться анонимными функциями(20 и 20 команды) и аллисами функций (18 команда)


***********************************************************************************************************************************************************************

1> rr("conv_info.hrl").

[conv_info]

2> c(converter).       

{ok,converter}

3> converter:rec_to_rub(#conv_info{type = usd, amount = 100, commission = 0.01}).

{ok,7549.0}

4> converter:rec_to_rub(#conv_info{type = peso, amount = 12, commission = 0.02}).

{ok,35.76}

5> converter:rec_to_rub(#conv_info{type = yene, amount = 30, commission = 0.02}).

Error arg {conv_info,yene,30,0.02}

{error,badarg}

6> converter:rec_to_rub(#conv_info{type = euro, amount = -15, commission = 0.02}).

Error arg {conv_info,euro,-15,0.02}

{error,badarg}

7> converter: map_to_rub(#{type => usd, amount => 100, commission => 0.01}).

{ok,7549.0}

8> converter: map_to_rub(#{type => peso, amount => 12, commission => 0.02}).

{ok,35.76}

9> converter: map_to_rub(#{type => yene, amount => 30, commission => 0.02}).

Error arg #{amount => 30,commission => 0.02,type => yene}

{error,badarg}

10> converter: map_to_rub(#{type => euro, amount => -15, commission => 0.02}).

Error arg #{amount => -15,commission => 0.02,type => euro}

{error,badarg}

11> c(recursion).     

{ok,recursion}

12> recursion:tail_fac(5). 

120

13> recursion:tail_fac(0). 

1

14> recursion:duplicate([1,2,3]). 

[1,1,2,2,3,3]

15> recursion:duplicate([]).      

[]

16> recursion:tail_duplicate([3,2,1]). 

[3,3,2,2,1,1]

17> recursion:tail_duplicate([]).      

[]

18> Fac = fun recursion:tail_fac/1.

fun recursion:tail_fac/1

19> Fac(5).  

120

20> Multiply = fun(X,Y) -> X*Y end.

#Fun<erl_eval.41.3316493>

21> Multiply(5,3).

15

22> ToRub = fun({usd, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 75.5}; ({euro, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 80};({lari, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 29};({peso, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 3};({krone, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 10};(Error) -> io:format("Error arg ~p~n",[Error]),{error, badarg} end.

#Fun<erl_eval.42.3316493>

23> ToRub({usd, 100}).

{ok,7550.0}

24> ToRub({peso, 12}).

{ok,36}

25> ToRub({yene, 30}).

Error arg {yene,30}

{error,badarg}

26> ToRub({euro, -15}).

Error arg {euro,-15}

{error,badarg}
