-module(coursework_http_handler).
-export([init/2]).

init(Req0, State)->
    Req = req_reply:reply_404(Req0),
    {ok, Req, State}.