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
    case chat_utils:find_chatter(User) of
      []->
        gproc:reg({n,l,User}, Pid),
        gproc:reg({p,l,Pid}, User);
      _ -> true
    end,
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


do_send_message(Pid, Message, #state{clients = Clients}) ->
    M1 = binary_to_list(Message),
    Msg = string:tokens(M1,"||"),
    User = list_to_binary(lists:nth(1, Msg)),
    Friend = list_to_binary(lists:nth(2,Msg)),    
    MsgOnly = lists:nth(3,Msg),
    io:format("Friend is ~p and message is ~p ~n" ,[Friend, MsgOnly]),
    chat_utils:write_message(User, Friend, MsgOnly),
    To = chat_utils:find_chatter(Friend),
    case To of 
      [] -> io:format("Friend isn't logged in\n"),
            friend_not_logged_in;
      _ ->
        io:format("To is ~p~n" ,[To]),
        To ! {send_message, self(), MsgOnly }
      end.
    %gproc:send({p, l, To}, {self(), To, MsgOnly}).

