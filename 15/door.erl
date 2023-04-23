%% @doc module for simulating the state of a door (open, closed, suspended) using the gen_statem behavior.
-module(door).
-behaviour(gen_statem).

-export([start/1, enter/1, print_entered/0, stop/0]).%% API
-export([init/1, callback_mode/0, locked/3, open/3, suspended/3, terminate/3]). %% Callback

%% @doc record of door data: count - count of imput attempts, code - code for opening the door, entered - list of user-entered values for opening the door
-record(data,{
    count = 0 :: non_neg_integer(),
    code :: list(non_neg_integer()),
    entered = [] :: list(non_neg_integer())
}).

%% API
%% @doc API function for spawn gen_statem process with code for opening the door
-spec(start(InitCode :: list(non_neg_integer())) -> 
    {ok, pid()}).
start(InitCode) ->
    gen_statem:start({local, ?MODULE}, ?MODULE, InitCode, []).

%% @doc API function synchronous call gen_statem process of the generic server, sending '{enter, Num}'
-spec(enter(Num :: non_neg_integer()) -> 
    {ok, next} | opened | {error, wrong_code} | {error, door_suspended} | {error, alredy_open} | {error, suspended}).
enter(Num) ->
    gen_statem:call(?MODULE, {enter, Num}).

%% @doc API function synchronous call gen_statem process of the generic server, sending 'print_entered'
-spec(print_entered() ->
    ok).
print_entered()->
    gen_statem:cast(?MODULE, print_entered).

%% @doc API function for stop gen_statem process to exit with 'normal' reason
-spec(stop() ->
    ok).
stop() ->
    gen_statem:stop(?MODULE).

%% Callback
init(InitCode) ->
    {ok, locked, #data{code = InitCode}}.

callback_mode()->
    state_functions.

locked({call, From}, {enter, Num}, #data{count = Count, code = Code, entered = Entered} = Data) ->
    NewEntered = [Num | Entered],
    case length(NewEntered) == length(Code) of
        false ->
            NewData = Data#data{entered = NewEntered},
            {keep_state, NewData, [{reply, From, {ok, next}}]};
        true ->
            case Code == lists:reverse(NewEntered) of
                false ->
                    case Count + 1 == 3 of
                        true ->
                            {next_state, suspended, Data#data{count = 0, entered = []}, [{reply, From, {error, suspended}}, {state_timeout, 10000, locked_timeout}]};
                        false ->
                            case Count + 1 of
                                1 -> 
                                    {keep_state, Data#data{count = Count + 1, entered = []}, [{reply, From, {error, wrong_code, two_attempts_left}}]};
                                2 ->
                                    {keep_state, Data#data{count = Count + 1, entered = []}, [{reply, From, {error, wrong_code, one_attempts_left}}]}
                            end   
                    end;
                true ->
                    {next_state, open, Data#data{count = 0, entered = []}, [{reply, From, opened}]}
            end
    end;
locked(cast, print_entered, #data{entered = Entered}) ->
    io:format("Entered ~p ~n", [lists:reverse(Entered)]),
    keep_state_and_data;
locked(info, Msg, _Data) ->
    io:format("Resived ~p ~n", [Msg]),
    keep_state_and_data.

open({call, From}, {enter, _Num}, _Data)->
    {keep_state_and_data, [{reply, From, {error, alredy_open}}]};
open(cast, print_entered, _Data) ->
    io:format("Already opened ~n"),
    keep_state_and_data;
open(info, Msg, _Data) ->
    io:format("Resived ~p ~n", [Msg]),
    keep_state_and_data.

suspended(state_timeout, locked_timeout, Data)->
    io:format("Timeout, the door will be locked ~n"),
    {next_state, locked, Data};
suspended({call, From}, {enter, _Num}, _Data)->
    {keep_state_and_data, [{reply, From, {error, door_suspended}}]};
suspended(cast, print_entered, _Data) ->
    io:format("Door locked ~n"),
    keep_state_and_data;
suspended(info, Msg, _Data) ->
    io:format("Resived ~p ~n", [Msg]),
    keep_state_and_data.

terminate(Reason, State, Data) ->
    io:format("Terminating reason ~p state ~p data ~p~n",[Reason, State, Data]),
    ok.