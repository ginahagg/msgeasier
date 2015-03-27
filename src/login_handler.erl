-module(login_handler).
-behaviour(cowboy_http_handler).

%-export([init/3]).
%-export([handle/2]).
%-export([terminate/3]).
-compile(export_all).

-record(state, {
}).


%[{"gina",1, {{2015,3,10},{19,21,7}},{friends,["marc","gina","david","elsa","pierre","lord"]}}]
%{"shaila-gina",2,{{2015,3,11},{19,21,7}},{{"shaila", {{2015,3,11},{19,2,49}}, "hey you how it is going?"},
%{"gina", {{2015,3,11},{19,3,49}}, "fine, how about you? "},{"shaila",{{2015,3,11},{19,4,59}}, "i am doing homework. can you believe it? "}}}).
init(_, Req, _Opts) ->
    chat_utils:initialize(),
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

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
     
    HasBody = cowboy_req:has_body(Req2),
    handle_req(Method, Req2, State,HasBody).


handle_req(<<"POST">>, Req, State, true)->
    {ok, Body, Req1}= cowboy_req:body(Req),
    io:format("body: ~p~n",[Body]),
    {ok, Reply} = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        Body,Req),
    %L = binary_to_list(Body),
    %T = string:tokens(L,"="),
    %User = lists:nth(2,T),
    {ok, Reply, State};

handle_req(<<"POST">>, Req, State,false)->
    {ok, Body, Req1}= cowboy_req:body(Req),
    io:format("body: ~p~n",[Body]),
    {ok, Reply} = cowboy_req:reply(405,
        [{<<"content-type">>, <<"text/plain">>}],
        "no data",Req),
    {ok, Reply, State};
    
handle_req(_, Req, State,false)->
    {ok, Reply} = cowboy_req:reply(405,
        [{<<"content-type">>, <<"text/plain">>}],
        "not allowed",Req),
    {ok, Reply, State}.

terminate(_Reason, _Req, _State) ->
	ok.

