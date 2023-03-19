# eltex_erlang_homework
Homework Erlang

В этой домашней я поработал с процессами и Bit Syntax в Erlang.

1 Задание:
В функции ipv4/1, я используя pattern matching binary сравнивал переданные в binary данные с форматом ipv4 и преобразовал binary в record.
При обработке случая, когда данные не матчатся я использовал exception:error т.к. при передаче неверных данных мы не можем в дальнейшем обработать переданные нам данные, выполнение процесса не имеет смысла.

2 Задание:
Реализация пункта 2.1 есть ниже в выполнениях команд.
В 2.2 Pid self процесса не меняется т.к. при помощи spawn/3 я создаю НОВЫЙ процесс, которы никак не связан с self(), поэтому ошибка в предыдущей строке завершает выполнения НОВОГО созданного процесса, а не процесса self().

3 Задание:
Реализовал функцию ipv4_listener, получает ожидает от процесса сообщения, которое отправляется при помощи !, запускает функцию protocol:ipv4(Data), если получает на вход верные параметры и вызывает exception, если данные не подходят по формату.

***********************************************************************************************************************************************************************

1> rr("protocol.hrl").

[ipv4]

2> c(protocol).

{ok,protocol}

3> DataWrongFormat = <<4:4, 6:4, 0:8, 0:3>>.

<<70,0,0:3>>

4> protocol:ipv4(DataWrongFormat).                        

** exception error: badmatch
     in function  protocol:ipv4/1 (protocol.erl, line 25)

5> DataWrongVer = <<6:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.

<<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
  101,108,108,111>>

6> protocol:ipv4(DataWrongVer).    

** exception error: badmatch
     in function  protocol:ipv4/1 (protocol.erl, line 25)

7> Data1 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.

<<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
  101,108,108,111>>

8> protocol:ipv4(Data1).        

Received data <<"hello">> 
#ipv4{version = 4,ihl = 6,tos = 0,total_length = 232,
      identification = 0,flags = 0,fragment_offset = 0,ttl = 0,
      protocol = 0,header_checksum = 0,source_address = 0,
      destination_address = 0,
      options = <<0,0,0,0>>,
      data = <<"hello">>}

9> Data2 = << 4:4, 6:4, 0:8, 200:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, 4:8 >>.

<<70,0,0,200,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4>>

10> protocol:ipv4(Data2). 

Received data <<4>> 
#ipv4{version = 4,ihl = 6,tos = 0,total_length = 200,
      identification = 0,flags = 0,fragment_offset = 0,ttl = 0,
      protocol = 0,header_checksum = 0,source_address = 0,
      destination_address = 0,
      options = <<0,0,0,0>>,
      data = <<4>>}

11> spawn(protocol, ipv4, [Data1]).          

Received data <<"hello">> 
<0.101.0>

12> self().                        
<0.95.0>

13> spawn(protocol, ipv4, [DataWrongVer]).

<0.104.0>
14> =ERROR REPORT==== 19-Mar-2023::21:38:34.339000 ===
Error in process <0.104.0> with exit value:
{badmatch,[{protocol,ipv4,1,[{file,"protocol.erl"},{line,25}]}]}

14> self().

<0.95.0>

15> ListenerPid = spawn(protocol, ipv4_listener, []).

<0.107.0>

16> ListenerPid ! {ipv4, self(), Data1}.

Received data <<"hello">> 
{ipv4,<0.95.0>,
      <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
        101,...>>}

17> flush().

Shell got {ipv4,4,6,0,232,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"hello">>}
ok

19> f(). 

ok

20> ListenerPid = spawn(protocol, ipv4_listener, []).

<0.83.0>

21> ListenerPid ! {{ipv4, 1}, "Wrong args"}.

{{ipv4,1},"Wrong args"}
22> =ERROR REPORT==== 19-Mar-2023::21:55:56.603000 ===
Error in process <0.83.0> with exit value:
{badarg,[{protocol,ipv4_listener,0,[{file,"protocol.erl"},{line,33}]}]}
