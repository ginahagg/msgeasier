-module(chat_room).
-behaviour(gen_server).

-export([start_link/0, enter/2, leave/1, send_message/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {clients=[]}).


%C1=#chat{owner=#client{pid=1,nm="gina"},from=#client{pid=2,nm="shaila"},to=#client{pid=3,nm="gina"}}.
%C1#chat.from#client.nm.

%%%=============================================================================
%%% API
%%%=============================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

enter(Pid, User) ->
    gen_server:cast(?SERVER, {enter, Pid, User}).

leave(Pid) ->
    gen_server:cast(?SERVER, {leave, Pid}).

send_message(Pid, Message) ->
    gen_server:cast(?SERVER, {send_message, Pid, Message}).

%%%=============================================================================
%%% gen_server callbacks
%%%=============================================================================


init([]) ->
  {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast({enter, Pid, User}, State = #state{clients = Clients}) -> 
    io:format("handlecast:enter User and pid is: ~p, ~p ~n",[User,Pid]),  
    gproc:reg({n,l,User}, Pid),
    gproc:reg({p,l,Pid}, User),
    {noreply, State#state{clients = [Pid|Clients]}};

handle_cast({leave, Pid}, State = #state{clients = Clients}) ->
    io:format("handlecast:leave pid is: ~p ~n",[Pid]), 
    User = chat_utils:find_chatter(Pid),
    gproc:unreg({p,l,Pid}),
    gproc:unreg({n,l,User}),
    {noreply, State#state{clients  = Clients -- [Pid]}};

handle_cast({send_message, Pid, Message}, State) ->
    do_send_message(Pid, Message, State),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    io:format("terminate: _Reason is: ~p ~n",[_Reason]), 
    cowboy:stop_listener(msgeasier).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



%%%=============================================================================
%%% Internal functions
%%%=============================================================================



%do_send_message(Pid, Message, #state{clients = Clients})  ->
%    do_send_message_orig(Pid, Message, State);
%do_send_message(Pid, Chatters,Message, State) ->
 %   {_, T} = Chatters,
 %   To = gproc:get_value({n,l,T}),
 %   io:format("do_send_message: from To is: ~p: ~p~n",[Pid, To]),
 %   To ! {send_message, Pid, Message},
 %   do_send_message_orig(Pid, Message,State).
      

do_send_message(Pid, Message, #state{clients = Clients}) ->
    M1 = binary_to_list(Message),
    Msg = string:tokens(M1,"||"),
    %User = lists:nth(1, Msg),
    Friend = lists:nth(2,Msg),    
    MsgOnly = lists:nth(3,Msg),
    io:format("Friend is ~p and message is ~p ~n" ,[Friend, MsgOnly]),
    To = chat_utils:find_chatter(list_to_binary(Friend)),
    io:format("To is ~p~n" ,[To]),
    To ! {send_message, self(), MsgOnly }.
    %gproc:send({p, l, To}, {self(), To, MsgOnly}).


do_send_message_pid(Pid, Message, #state{clients = Clients}) ->   
    OtherPids = Clients -- [Pid],
    io:format("do_send_message: clients are: ~p, ~p: ~n",[Clients, OtherPids]),
    lists:foreach(
      fun(OtherPid) ->
              io:format("do_send_message: sending message to ~p: ~n",[OtherPid]),
              %case chat_utils:find_chatter(OtherPid) of 
              %[] ->
              %gproc:reg({p,l,OtherPid},"other");
              %_->OtherPid 
              %end,
              %gproc:send({p, l, OtherPid}, {self(), OtherPid, Message}) 
              OtherPid ! {send_message, self(), Message}
      end, OtherPids).
