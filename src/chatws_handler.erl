%% Copyright (c) 2015, Chris Maguire <cwmaguire@gmail.com>
%% Copyright (c) 2015, Gina Hagg
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

%% Demonstrate websocket handling
-module(chatws_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {}).

init(_, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

%websocket_init(_Type, Req, _Opts) ->
%    io:format("Websocket handler init~n"),
 %   Req3 = case cowboy_req:parse_header(<<"sec-websocket-protocol">>, Req) of
%        {ok, undefined, Req2} ->
%            Req2;
%        {ok, Subprotocols, Req2} ->
%            io:format("Subprotocols found: ~p~n", [Subprotocols]),
%            Req2
%    end,
%    register(websocket, self()),
%    websocket ! "message sent from init",
%    {ok, Req3, #state{}}.

websocket_init(_TransportName, Req, _Opts) ->
    chat_utils:initialize(),
    {AllValues, Req2} = cowboy_req:qs_vals(Req),
    [{_, User}] = AllValues,
    chat_room:enter(self(),User),
    {ok, Req, #state{}}.

%{text, <<"enter:gina">>
websocket_handle({FrameType, Message}, Req, State) ->
    io:format("websocket handle: {~p, ~p}~n", [FrameType, Message]),
    %chat_room:send_message(self(), {list_to_binary(User),list_to_binary(Friend)},MsgOnly),
    chat_room:send_message(self(), Message),
    
    %{reply, {text, ["Erlang received: ", FrameContent, " of type ", atom_to_list(FrameType)]}, Req, State}.
    {ok, Req, State};

websocket_handle(_Data, Req, State) ->
    io:format("websocket_handler: data: ~p:~n",[_Data]),
    {ok, Req, State}.

websocket_info({send_message, _ServerPid, Msg}, Req, State) ->
    io:format("websocket_info: serverPid and Msg: ~p: ~p ~n",[_ServerPid, Msg]),
    {reply, {text, Msg}, Req, State};

websocket_info(_Info, Req, State) ->
    io:format("websocket_info: info: ~p: ~p ~n",[_Info]),
    {ok, Req, State}.

handle(Req, State=#state{}) ->
    {ok, Req, State}.

terminate(_Reason, _Req, _State) ->
    io:format("terminate: _Reason is: ~p ~n",[_Reason]), 
	chat_room:leave(self()),
    {ok, _Req, _State}.

