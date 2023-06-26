-module(abonent_http_handler).

-export([init/2, abonent/3]).

-include("abonents.hrl").

init(Req0, State)->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Req = abonent(Method, HasBody, Req0),
    {ok, Req, State}.
        

abonent(<<"GET">>, _, Req0)->
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
            try
                list_to_integer(binary:bin_to_list(Bin_Number)),
                {atomic, List_data} = database:get_abonent(list_to_integer(binary:bin_to_list(Bin_Number))),
                req_reply:reply_abonent_data(List_data, Req0)
            catch error:badarg ->
                req_reply:reply_error(<<"number">>, <<"Please enter abonent's number in integer format">>, Req0)
            end;
        _ ->
            req_reply:reply_error(<<"number">>, <<"Please enter abonent's number">>, Req0)
    end;

abonent(<<"POST">>, true, Req0)->
    {ok, DataBin, _Req} = cowboy_req:read_body(Req0),
    DataDecoded = jsone:decode(DataBin),
    case DataDecoded of
        #{<<"name">> := _,<<"num">> := _} ->
            {atomic, List_data} = database:get_abonent(maps:get(<<"num">>, DataDecoded)),
            case List_data of
                [] ->
                    database:add_abonent(DataDecoded),
                    req_reply:reply_result(<<"Abonent added">>, Req0);
                _ -> 
                    req_reply:reply_result(<<"Abonent already exists">>, Req0)
            end;
        _ ->
            req_reply:reply_error(<<"num, name">>, <<"Please enter abonent's number and name">>, Req0)
    end;

abonent(<<"DELETE">>, _, Req0)->
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
            try
                list_to_integer(binary:bin_to_list(Bin_Number)),
                {atomic, List_data} = database:get_abonent(list_to_integer(binary:bin_to_list(Bin_Number))),
                case List_data of
                    [] ->
                        req_reply:reply_result(<<"Abonent not found">>, Req0);
                    _ ->
                        [{abonents, Number, Name}] = List_data,
                        database:delete_abonent(Number, Name),
                        req_reply:reply_result(<<"Abonent deleted">>, Req0)
                end
            catch error:badarg ->
                req_reply:reply_error(<<"number">>, <<"Please enter abonent's number in integer format">>, Req0)
            end;
    _ ->
        req_reply:reply_error(<<"number">>, <<"Please enter abonent's number">>, Req0)
    end;

abonent(_, _, Req0)->
    req_reply:reply_404(Req0).