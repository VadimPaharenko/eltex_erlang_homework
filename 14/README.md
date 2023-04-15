# eltex_erlang_homework
Homework Erlang

1> c(keylist).

{ok,keylist}

2> c(keylist_mgr).

{ok,keylist_mgr}

3> keylist_mgr:start_monitor().

{ok,{<0.94.0>,#Ref<0.16266995.2915565580.187268>}}

4> rr("process_data.hrl").      

[process_data]

5> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).

{ok,<0.99.0>}

6> keylist:add(keylist1, key1, "value1", "comment1").

ok

7> keylist:add(keylist1, key2, "value1", "comment1").

ok

8> keylist:add(keylist1, key3, "value2", "comment2").

ok

9> keylist:add(keylist1, key4, "value3", "comment3").

ok

10> keylist:match(keylist1, '$1').

{ok,[[#process_data{key = key1,value = "value1",
                    comment = "comment1"}],
     [#process_data{key = key2,value = "value1",
                    comment = "comment1"}],
     [#process_data{key = key3,value = "value2",
                    comment = "comment2"}],
     [#process_data{key = key4,value = "value3",
                    comment = "comment3"}]]}

11> keylist:match(keylist1, #process_data{key='$1', value="value1", comment='$2'}).

{ok,[[key1,"comment1"],[key2,"comment1"]]}

12> keylist:match(keylist1, #process_data{key='$1', value='$2', comment="comment2"}).

{ok,[[key3,"value2"]]}

13> keylist:match_object(keylist1, #process_data{value="value1", _ = '_'}).

{ok,[#process_data{key = key1,value = "value1",
                   comment = "comment1"},
     #process_data{key = key2,value = "value1",
                   comment = "comment1"}]}

14> keylist:match_object(keylist1, #process_data{comment="comment2", _ = '_'}).

{ok,[#process_data{key = key3,value = "value2",
                   comment = "comment2"}]}

15> keylist:select(keylist1, fun(#process_data{key = Key, value = Value, comment = Comment}) when Value == "value1" -> [Key, Comment] end).

{ok,[[key1,"comment1"],[key2,"comment1"]]}

16> keylist:select(keylist1, fun(#process_data{key = Key, value = Value, comment = Comment}) when Comment == "comment2" -> [Key, Value] end).

{ok,[[key3,"value2"]]}