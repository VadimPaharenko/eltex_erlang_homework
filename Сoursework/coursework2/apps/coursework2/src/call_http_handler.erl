-module(call_http_handler).

-export([init/2, call/2]).

-include("abonents.hrl").


init(Req0, State)->
    Method = cowboy_req:method(Req0),
    Req = call(Method, Req0),
    {ok, Req, State}.


call(<<"GET">>, Req0)->
    case cowboy_req:parse_qs(Req0) of
        [{<<"number">>, Bin_Number}] ->
            try
                list_to_integer(binary:bin_to_list(Bin_Number)),
                {atomic, List_data} = database:get_abonent(list_to_integer(binary:bin_to_list(Bin_Number))),
                case List_data of
                    [] -> 
                        req_reply:reply_result(<<"Number not found">>, Req0);
                    _ ->
                        dialer:call(binary:bin_to_list(Bin_Number)),
                        req_reply:reply_result(<<"Call started">>, Req0)
                end
            catch error:badarg ->
                req_reply:reply_error(<<"number">>, <<"Please enter abonent's number in integer format">>, Req0)
            end;
                _ ->
            req_reply:reply_error(<<"number">>, <<"Please enter abonent's number">>, Req0)
    end;

call(_, Req0)->
    req_reply:reply_404(Req0).