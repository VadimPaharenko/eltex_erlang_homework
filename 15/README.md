# eltex_erlang_homework
Homework Erlang

Поработал с gen_statem, написал модуль имитирующий поведение двери с кодом для открытия.

Для релизациии state = suspended добавил в record data элемент count в котором хранится кол-во попыток введения кода двери.

Написал тесты для проверки неправильного и правильного написания кода от двери.

*************************************************************************************************************************************************
****

1> c(door).

{ok,door}

2> door:start([1,2,3,4]).

{ok,<0.87.0>}

3> door:enter(1).

{ok,next}

4> door:enter(2).

{ok,next}

5> door:enter(3).

{ok,next}

6> door:enter(3). 

{error,wrong_code,two_attempts_left}

7> door:enter(1).

{ok,next}

8> door:enter(2).

{ok,next}

9> door:enter(3).

{ok,next}

10> door:enter(3).

{error,wrong_code,one_attempts_left}

11> door:enter(1).

{ok,next}

12> door:enter(2).

{ok,next}

13> door:enter(3).

{ok,next}

14> door:enter(3).

{error,suspended}

15> door:enter(1).

{error,door_suspended}

16> door:enter(2).

{error,door_suspended}

17> Timeout, the door will be locked 

17> door:enter(1). 

{ok,next}

18> door:enter(2).

{ok,next}

19> door:enter(3).

{ok,next}

20> door:enter(4).

opened

21> door:stop().

Terminating reason normal state open data {data,0,[1,2,3,4],[]}
ok

22> c(door_test).

{ok,door_test}

23> eunit:test(door_test).
  Test passed.
ok