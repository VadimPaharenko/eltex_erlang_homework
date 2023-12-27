# eltex_erlang_homework
Homework Erlang

1> string:tokens("Hello world!", " "). %% разбивает строку "Hello world!" по разделителю " " и создает список разделенных строк    

["Hello","world!"]

2> string:join(["Hello", "world!"], " "). %% объединяет список строк ["Hello", "world!"] в строку с разделителем " "

"Hello world!"

3> string:strip(" Hello world! "). %% убирает пробелы в начале и конце строки

"Hello world!"

4> string:strip(" Hello world! ", left). %% убирает пробелы в заданном месте, в моем кейсе слева

"Hello world! "

5> string:to_upper("hello world!"). %% преобразует строку в верхний регистр

"HELLO WORLD!"

6> string:to_lower("HELLO WORLD!"). %% преобразует строку в нижний регистр

"hello world!"

7> string:to_integer("12345Hello world!"). %% разделяет строку в которой есть integer на кортеж из integer и строку

{12345,"Hello world!"}

8> list_to_integer("12345"). %% преобразует строку в которой есть integer в integer

12345

9> byte_size(<<"Hello world!">>). %% возвращает кол-во байт, которое занимает строка

12

10> split_binary(<<"Hello world!">>, 6). %% разбивает binary на кортеж binary по позиции

{<<"Hello ">>,<<"world!">>}

11> binary_part(<<"Hello world!">>, 6, 6). %% возвращает 6 позиций binary после позиции 6 

<<"world!">>

12> binary:split(<<"Привет мир!"/utf8>>, [<<" ">>]). %% разделяет bynary по разделителю, позволяет работать с кодировкой /utf8 (VS code не выводит в нормальном виде)

[<<194,143,195,160,194,168,194,162,194,165,195,162>>,
 <<"┬м┬и├а!">>]

13> binary:match(<<"Hello world">>, <<"o">>). %% выполняет поиск первого вхождения шаблона в binary, возвращает позицию и длину

{4,1}

14> binary:matches(<<"Hello world">>, <<"o">>). %% выполняет поиск всех вхождений шаблона в binary, возвращает список позиций и длинн

[{4,1},{7,1}]

15> binary:replace(<<"hello world">>, <<"h">>, <<"H">>). %% заменят шаблон в binary на другой шаблон

<<"Hello world">>

16> binary_to_list(<<"Hello world!">>). %% преобразовывает bynari в строку

"Hello world!"

17> list_to_binary("Hello world!"). %% преобразовывает строку в bynari

<<"Hello world!">>

18> lists:flatten(["Hello", [" world", "!"]]). %% объединяет спосок строк в одну строку

"Hello world!"