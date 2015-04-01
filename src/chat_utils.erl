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
        dets:open_file(?CHATROOM_TABLE,[{access,read_write},{type, bag}, {file, "/Users/ginahagg/mywork/msgeasier/msgeasier/chatroom"}]),
        {ok, ?CHATROOM_TABLE};
    true -> {ok, ?CHATROOM_TABLE}
    end;

dets_new_cache(2) ->
    All = dets:all(),
    case lists:member(?MESSAGES_TABLE, All) of false ->
        dets:open_file(?MESSAGES_TABLE,[{access,read_write},{type, bag}, {file, "/Users/ginahagg/mywork/msgeasier/msgeasier/messages"}]),
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


find_friends(Key) ->
    dets_new_cache(1),
    case dets:lookup(?CHATROOM_TABLE, Key) of
    [] ->
        {error, not_found};
    [{Key, Value}] -> {ok, Value}
    end.

find_messages(Key) ->
    dets_new_cache(2),
    case dets:lookup(?MESSAGES_TABLE, Key) of
    [] ->
        {error, not_found};
    [{Key, Value}] -> {ok, Value}
    end.


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

%<<"gina-shaila">> i.e
get_messages(From,To)->
    {ok, messages} = dets_new_cache(2),
    %dets:select(messages,[{{'$2','$3','$1','$4'},[{'and',{'==', '$2', <<"gina">>},{'==', '$3', <<"marc">>}}],['$$']}]).
    L1 = dets:select(messages,[{{'$2','$3','$1','$4'},[{'and',{'==', '$2', From},{'==', '$3', To}}],['$$']}]),
    L2 = dets:select(messages,[{{'$2','$3','$1','$4'},[{'and',{'==', '$2', To},{'==', '$3', From}}],['$$']}]),
    %U = dets:match(messages,{From,To,'$1','$2'}),
    %UL = [[From] ++ [To] ++ X || X <- U],
    jsx:encode(L1++L2). 


find_all_messages(Which)->
    {ok, Table} = dets_new_cache(Which),
    dets:match(Table, '$1').


get_friends(User)->
    dets_new_cache(1),
    [Fs] = dets:lookup(?CHATROOM_TABLE, User),
    io:format("Fs: ~p~n",[Fs]),
    {_,_,Dt,{_,Frs}}=Fs,
    Frss = lists:map(fun(X) -> 
        case chat_utils:find_chatter(list_to_binary(X)) of
            [] -> X ++ "-off";
            _  -> X ++ "-on"
        end
    end, Frs),
    Fss = string:join(Frss,"||").

write_message (User,Friend, Message)->  
    dets_new_cache(2),
    Dt2=list_to_binary(qdate:to_string("Y-m-d H:i:s",calendar:local_time())),
    dets:insert(?MESSAGES_TABLE, {list_to_binary(User),list_to_binary(Friend),Dt2, list_to_binary(Message)}).

-define(GREGORIAN_SECONDS_1970, 62167219200).
%-define(GREGORIAN_SECONDS_1970, calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {0,0,0}}).
datetime_to_now(DateTime) ->
    GSeconds = calendar:datetime_to_gregorian_seconds(DateTime),
    ESeconds = (GSeconds - ?GREGORIAN_SECONDS_1970) * 1000.
