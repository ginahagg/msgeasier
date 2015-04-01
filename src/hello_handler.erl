-module(hello_handler).
-behaviour(cowboy_http_handler).

%-export([init/3]).
%-export([handle/2]).
%-export([terminate/3]).
-compile(export_all).

-record(state, {
}).

-define(MESSAGES_TABLE, messages).
-define(CHATROOM_TABLE, chatroom).


%[{"gina",1, {{2015,3,10},{19,21,7}},{friends,["marc","gina","david","elsa","pierre","lord"]}}]
%{"shaila-gina",2,{{2015,3,11},{19,21,7}},{{"shaila", {{2015,3,11},{19,2,49}}, "hey you how it is going?"},
%{"gina", {{2015,3,11},{19,3,49}}, "fine, how about you? "},{"shaila",{{2015,3,11},{19,4,59}}, "i am doing homework. can you believe it? "}}}).
init(_, Req, _Opts) ->
	{ok, Req, #state{}}.

%handle(Req, State=#state{}) ->
 %   {Method, Req2} = cowboy_req:method(Req),
 %   {User, Req2} = cowboy_req:binding(user,Req),
 %   {Typ, Req3} = cowboy_req:binding(typ,Req),
 %   HasBody = cowboy_req:has_body(Req3),
 %   {Body,Req4} = cowboy_req:body(Req3),
 %   io:format("User: ~p",[User]),
 %   io:format("Typ: ~p",[Typ]),
 %   io:format("HasBody: ~p~n",[HasBody]),
 %   io:format("Body: ~p~n",[Body]),
  %  %handle_req(Typ,User,Req, State).
 %   {ok, Req4, State}.

handle(Req, State=#state{}) ->
    {Method, Req2} = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),
    io:format("Method: ~s and has:body: ~p~n",[Method, HasBody]),
    case Method of
        <<"POST">> ->
            %Body = <<"<h1>This is a response for POST</h1>">>,
            {User, Req3} = cowboy_req:binding(user,Req2),
            %Bs = cowboy_req:bindings(Req3),
            Path = cowboy_req:path(Req3),
            %{[Bins],_} = Bs,
            % io:format("Bins: ~p~n ",[Bins]),  
            io:format("---------Path: ~p~n",[Path]),
            {ok, Body, Req4}= cowboy_req:body(Req3),
            io:format("Body: ~p~n ",[Body]),       
            %write_message(User, Body),
            cowboy_req:reply(200, [], Body, Req4);
        <<"GET">> ->
             {User, Req3} = cowboy_req:binding(user,Req2),           
             {Typ, Req4} = cowboy_req:binding(typ,Req3),
             handle_req(Typ,User,Req4, State);
        _ ->
            Body = <<"<h1>This is a response for other methods</h1>">>,
            {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
            {ok, Req3, State}
    end.


handle_req(<<"1">>, User, Req,State)->
    io:format("type 1: User: ~p",[User]),
    Fs = chat_utils:get_friends(User),   
    io:format("~s~n",[Fs]),
    {ok,Req2} = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        Fs,Req),
    {ok, Req2, State};

handle_req(<<"2">>, User, Req, State)->
    {Friend, Req1} = cowboy_req:binding(friend,Req),
    io:format("type 2: User: ~p, Friend: ~p",[User, Friend]),
    M = chat_utils:get_messages(User, Friend),   
    io:format("~p~n",[M]),
    %M = "shaila,2015-03-11|07:02pm,hey|you|how|it|is|going",
    %Ms = jsx:encode(M),
    {ok,Req2} = cowboy_req:reply(200,
        %[{<<"content-type">>, <<"text/plain">>}],
        [{<<"content-type">>, <<"application/json">>}],
        M,Req1),
    {ok, Req2, State};

handle_req(_, User, Req, State) ->
    handle_req(1,User,Req, State).


terminate(_Reason, _Req, _State) ->
	ok.	

initialize() ->
    application:start(sasl),
    application:start(inets),
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl).






    	
