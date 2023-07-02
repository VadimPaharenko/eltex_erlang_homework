-module(dialer).

-include_lib("../nksip/include/nksip.hrl").

-export([start/0, stop/0]).
-export([invite/1, call/1]).

start() ->
    StartOptions = #{
        sip_from => "sip:101@test.domain",
        plugins => [nksip_uac_auto_auth],
        sip_listen => "<sip:all:5060;transport=udp>"
    },

    case nksip:start_link(test_ip_set, StartOptions) of
        {ok, _} -> {ok, starting};
        {error, {already_started, _}} -> {ok, started};
        {error, Reason} -> erlang:exit(Reason)
    end,

    RegisterOptions = [
        {sip_pass, "1234"},
        contact,
        {meta, ["contact"]}
    ],
    
    nksip_uac:register(test_ip_set, "sip:10.0.20.11", RegisterOptions).

stop()->
    nksip:stop(test_ip_set).


call(Phone)->
    case start() of
        {ok, 200, []} ->
            case invite(Phone) of
                {ok, DialogId} ->
                    {ok, DialogMeta} = nksip_dialog:get_meta(invite_remote_sdp, DialogId),
                    %{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,Media} = DialogMeta,
                    %[{_,_,Port,_,_,_,_,_,_,_,_}] = Media,
                    Port = (hd(DialogMeta#sdp.medias))#sdp_m.port,
                    ConvertVoice = "ffmpeg -i /files/generate.wav -codec:a pcm_mulaw -ar 8000 -ac 1 /files/output.wav -y",
                    StartVoice = "/voice_client /files/output.wav 10.0.10.11 " ++ erlang:integer_to_list(Port),
                    Cmd = ConvertVoice ++ " && " ++ StartVoice,
                    Res = os:cmd(Cmd),
                    nksip_uac:bye(DialogId, []);
                Err ->
                    Err
                end;
        Err ->
            Err
    end.

invite(Phone)->
    SDP = nksip_sdp:new("10.0.20.11", [{<<"audio">>, 9990, [{rtpmap, 0, "PCMU/8000"}, {rtpmap, 101, "telephone-event/8000"}, sendrecv]}]),

    InviteOptions = [
        auto_2xx_ack,
        {add, "x-nk-prov", true},
        {add, "x-nk-op", ok},
        {add, "x-nk-sleep", 10000},
        {sip_dialog_timeout, 10000},
        {sip_pass, "1234"},
        {body, SDP},
        {route, "<sip:10.0.20.11;lr>"}
        ],
    
    case nksip_uac:invite(test_ip_set, "sip:" ++ unicode:characters_to_list(Phone) ++ "@test.domain", InviteOptions) of
        {ok, 200, [{dialog, DialogId}]} -> 
            {ok, DialogId};

        {error,service_not_started} ->
            start(),
            invite(Phone);

        Err -> 
            Err
    end.
