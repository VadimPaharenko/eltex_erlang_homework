# eltex_erlang_homework
Homework Erlang

Надеюсь, что я правильно понял задание и при создании функций any, all, filter и update не нужно было пользоваться функциями из модуля lists)
Я знаком с этими функциями и знаю как они работают, сравнивал выполнение моих функция с функциями из этого модуля.

В модуле persons реализовал несколько функций аналогичных функциям из модуля lists, не используя этот модуль, это помогает в понимании того, как эти функции работают внутри.
Еще раз с прошлой ДЗ использовал анонимные и рекурсивные функции. Так же научился пользоваться "сверткой" списков(lists:foldl) при создании функции get_average_age. Так же создал макросы на определение gender = male и gender = female, но в программе они не пригодились.

Во второй части задания попрактиковался в создании списков при помощи конструктора списков, синтаксис очень похож на матиматические выражения ({x | x ∈ {1,2,3,4,5,6,7,8,9,10}, x mod 3 = 0}

В модуле exceptions посмотрел как используется обработчик ошибок "try catch" в Erlang.
При выполнении exceptions:catch_all(fun() -> 1/0 end). - попадаем в eror, т.к. происходит деление на 0, Reason = badarith.
При выполнении exceptions:catch_all(fun() -> throw(custom_exceptions) end). - попадаем в throw, т.к. самостоятельно его вызываем Reason = custom_exceptions.
При выполнении exceptions:catch_all(fun() -> exit(killed) end). - попадаем в exit, т.к. самостоятельно его вызываем Reason = killed.
При выполнении exceptions:catch_all(fun() -> erlang:error(runtime_exception) end). - попадаем в error, т.к. самостоятельно его вызываем Reason = runtime_exception.

***********************************************************************************************************************************************************************

1> rr("person.hrl").

[person]

2> c(persons).

{ok,persons}

3> Persons = [#person{id=1, name="Bob", age=23, gender=male}, #person{id=2, name="Kate", age=20, gender=female}, #person{id=3, name="Jack", age=34, gender=male}, #person{id=4, name="Nata", age=54, gender=female}].

[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]

4> persons:filter(fun(#person{age = Age}) -> Age >= 30 end, Persons).

[#person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]

5> persons:filter(fun(#person{gender = Gender}) -> Gender =:= male end, Persons).

[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 3,name = "Jack",age = 34,gender = male}]

6> persons:any(fun(#person{gender = Gender}) -> Gender =:= female end, Persons).

true

7> persons:all(fun(#person{age = Age}) -> Age >= 20 end, Persons).

true

8> persons:all(fun(#person{age = Age}) -> Age =< 30 end, Persons).

false

9> UpdateJackAge = fun(#person{name = ”Jack”, age = Age} = Person) -> Person#person{age=Age + 1}; (Person) -> Person end. 

#Fun<erl_eval.42.3316493>

10> persons:update(UpdateJackAge, Persons).

[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 35,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]

11> UpdateFemalesAge = fun(#person{gender = female, age = Age} = Female) -> Female#person{age=Age - 1};(Female) -> Female end.

#Fun<erl_eval.42.3316493>

12> persons:update(UpdateFemalesAge, Persons). 

[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 19,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 53,gender = female}]

13> [X || X <- lists:seq(1,10), X rem 3 =:= 0].

[3,6,9]

14> [Y*Y || Y <- [1, "hello", 100, boo, "boo", 9], is_integer(Y)].

[1,10000,81]

15> c(exceptions).

{ok,exceptions}

16> exceptions:catch_all(fun() -> 1/0 end).

Action #Fun<erl_eval.43.3316493> failed, reason badarith 
error

17> exceptions:catch_all(fun() -> throw(custom_exceptions) end).

Action #Fun<erl_eval.43.3316493> failed, reason custom_exceptions
throw

18> exceptions:catch_all(fun() -> exit(killed) end).

Action #Fun<erl_eval.43.3316493> failed, reason killed 
exit

19> exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).

Action #Fun<erl_eval.43.3316493> failed, reason runtime_exception 
error
