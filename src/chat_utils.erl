-module(chat_utils).

%-export([init/3]).
%-export([handle/2]).
%-export([terminate/3]).
-compile(export_all).

-define(MESSAGES_TABLE, messages).
-define(CHATROOM_TABLE, chatroom).

initialize() ->
    application:start(sasl),
    application:start(inets),
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl).


dets_new_cache(1) ->
    All = dets:all(),
    case lists:member(?CHATROOM_TABLE, All) of false ->
        dets:open_file(?CHATROOM_TABLE,[{access,read_write},{type, bag}, {file, "/Users/ginahagg/mywork/hello_erlang/chatroom"}]),
        {ok, ?CHATROOM_TABLE};
    true -> {ok, ?CHATROOM_TABLE}
    end;

dets_new_cache(2) ->
    All = dets:all(),
    case lists:member(?MESSAGES_TABLE, All) of false ->
        dets:open_file(?MESSAGES_TABLE,[{access,read_write},{type, bag}, {file, "/Users/ginahagg/mywork/hello_erlang/messages"}]),
        {ok, ?MESSAGES_TABLE};
    true -> {ok, ?MESSAGES_TABLE}
    end.
    

dets_save_detail(1, Key, Detail) ->
    dets_new_cache(1),
    dets:insert_new(?CHATROOM_TABLE, {Key, Detail}),
    {ok,Detail};

dets_save_detail(2, Key, Detail) ->
    dets_new_cache(2),
    dets:insert_new(?MESSAGES_TABLE, {Key, Detail}),
    {ok,Detail}.

dets_write_message(Key,Body) ->
    %Nowtime = datetime_to_now(calendar:now_to_universal_time(now())),      
    dets_new_cache(2),
    %<<"From=gina&To=shaila&msg=this+issue+is+very+important..">>
    %io:format("Body: ~p~n",[Body]),    
    dets:insert(?MESSAGES_TABLE, {Key,calendar:local_time(), Body}).


dets_lookup_key(1, Key) ->
    dets_new_cache(1),
    case dets:lookup(?CHATROOM_TABLE, Key) of
    [] ->
        {error, not_found};
    [{Key, Value}] -> {ok, Value}
    end;

dets_lookup_key(2, Key) ->
    dets_new_cache(2),
    case dets:lookup(?MESSAGES_TABLE, Key) of
    [] ->
        {error, not_found};
    [{Key, Value}] -> {ok, Value}
    end.

dets_check_save(1, Key,Detail)->
    dets_new_cache(1),
    Val = case dets_lookup_key(1,Key) of
        {error, not_found} ->
        {ok, Det} = dets_save_detail(1, Key,Detail),
        Det;
        {ok, Value} -> Value
    end,
    {ok, Val};

dets_check_save(2, Key,Detail)->
    dets_new_cache(1),
    Val = case dets_lookup_key(2,Key) of
        {error, not_found} ->
        {ok, Det} = dets_save_detail(2,Key,Detail),
        Det;
        {ok, Value} -> Value
    end,
    {ok, Val}.

find_chatter(Key)->
  GProcKey = {'_','_',Key},
  MatchHead = {GProcKey, '_','_'},
  R= gproc:select([{MatchHead,[],['$$']}]),
  io:format("R: ~p~n" , [R]),
  case R of
    [] -> [];
     _ ->
    [[_,_,R1]] = R,
    R1 
  end.

find_all()->
gproc:select([{'_',[],['$$']}]).

handle_chatter({User,Pid},[]) ->
  gproc:reg({n,l,User}, Pid);

handle_chatter({User,Pid}, Chatter) ->
  true.

register_user (User,Pid) ->
  Chatter = find_chatter(User),
  io:format("register_user: Chatter is: ~p~n",[Chatter]),
  handle_chatter({User,Pid},Chatter).
