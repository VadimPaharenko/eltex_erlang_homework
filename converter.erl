-module(converter).
-include("conv_info.hrl").
-export([rec_to_rub/1, map_to_rub/1]).

rec_to_rub(#conv_info{type = usd, amount = Amount, commission = Commission})when is_integer(Amount), Amount > 0 ->
    Result = Amount * 75.5,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
rec_to_rub(#conv_info{type = euro, amount = Amount, commission = Commission})when is_integer(Amount), Amount > 0 ->
    Result = Amount * 80,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
rec_to_rub(#conv_info{type = lari, amount = Amount, commission = Commission})when is_integer(Amount), Amount > 0 ->
    Result = Amount * 29,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
rec_to_rub(#conv_info{type = peso, amount = Amount, commission = Commission})when is_integer(Amount), Amount > 0 ->
    Result = Amount * 3,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
rec_to_rub(#conv_info{type = krone, amount = Amount, commission = Commission})when is_integer(Amount), Amount > 0 ->
    Result = Amount * 10,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
rec_to_rub(Error) ->
    io:format("Error arg ~p~n",[Error]),
    {error, badarg}.

map_to_rub(#{type := usd, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 75.5,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
map_to_rub(#{type := euro, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 80,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
map_to_rub(#{type := lari, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 29,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
map_to_rub(#{type := peso, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 3,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
map_to_rub(#{type := krone, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 10,
    CommissionResult = Amount * Commission,
    {ok, Result - CommissionResult };
map_to_rub(Error) ->
    io:format("Error arg ~p~n",[Error]),
    {error, badarg}.