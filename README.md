# eltex_erlang_homework
Homework Erlang

В этой домашней работе я ознакомился с работой функций в Erlang.
Посмотрел как работает guard "when" и "case" условия.

В результате было реализовано 3 функции, которвые выполняют одинаковые действия, но реализованы по разному.
Функция to_rub - обрабатывает входные значения при помощи нескольких тел функции и использует pattern matching при обработке параметров каждого из тел. Результат выполнения функции содержится в том теле, обрабатываемые параметры которого, совпадут с переданными параметрами.
Функция to_rub2 содержит одно тело функции и обрабатывает входные параметры через pattern mathing используя условия "case", результат выполнения "case" записывается в переменную "Result". Переменная "Result" стоит в конце функции и является ее возвращаемым значением.
Функция to_rub3 аналогично to_rub2 состоит из одного тела и использует "case" для сопоставления с образцом, однако результат выполенения "case" никуда не записывается, а сразу выводится как результат выполнения функции.

В результате мне удалось на примере посмотреть, что одинаковые по результату выполнения функции, можно реализовывать при помощи разных возможностей языка Erlang.

*************************************************************************************************************************************************************************
1> c(converter).
{ok,converter}
2> converter:to_rub({usd, 100}).
Convert usd to rub, amount 100
{ok,7550.0}
3> converter:to_rub({peso, 12}).
Convert peso to rub, amount 12
{ok,36}
4> converter:to_rub({yene, 30}).
Error arg {yene,30}
{error,badarg}
5> converter:to_rub({euro, -15}).
Error arg {euro,-15}
{error,badarg}
6> converter:to_rub2({usd, 100}).
Convert usd to rub, amount 100
{ok,7550.0}
7> converter:to_rub2({peso, 12}).
Convert peso to rub, amount 12
{ok,36}
8> converter:to_rub2({yene, 30}).
Can't convert to rub, error {yene,30}
{error,badarg}
9> converter:to_rub2({euro, -15}).
Can't convert to rub, error {euro,-15}
{error,badarg}
10> converter:to_rub3({usd, 100}).
Convert usd to rub, amount 100
{ok,7550.0}
11> converter:to_rub3({peso, 12}). 
Convert peso to rub, amount 12
{ok,36}
12> converter:to_rub3({yene, 30}).
Can't convert to rub, error {yene,30}
{error,badarg}
13> converter:to_rub3({euro, -15}).
Can't convert to rub, error {euro,-15}
{error,badarg}
