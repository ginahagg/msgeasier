-module(beacon_ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-define(BEACON_NAMES,[<<"beacon1">>,<<"beacon2">>,<<"beacon3">>,<<"beacon4">>]).

init({tcp, http}, _Req, _Opts) ->
    erlang:start_timer(1000, self(), <<"start">>),
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    %chat_room:enter(self()),
    {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
    %io:format("selfpid: ~p ~n", [self()]),
    {reply, {text, Msg}, Req, State};

websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
    M = build_message(),
    erlang:start_timer(5000, self(), M),
    {reply, {text, Msg}, Req, State};

websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    {ok, _Req, _State}.


build_message()->
    L = lists:map(fun(X)-> [{name,X}, {lat, get_latitude_()}, {lon, get_longitude_()}] end, ?BEACON_NAMES),
    Stamp = integer_to_list(calendar:datetime_to_gregorian_seconds(calendar:now_to_universal_time(now()))),
    TL = [{name,iolist_to_binary([<<"beacon">>|Stamp])}, {lat, get_latitude_()},  {lon, get_longitude_()}],
    jsx:encode(L ++ [TL]).

get_longitude_() ->
    MaxReasonable = 900,
    MinReasonable = 20,
    max(random:uniform(MaxReasonable), MinReasonable).
    
get_latitude_() ->
    MaxReasonable = 600,
    MinReasonable = 20,
    max(random:uniform(MaxReasonable), MinReasonable).

