-module(hello_erlang_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

-define(NO_OPTIONS, []).
-define(ANY_HOST, '_').

start(_Type, _Args) ->

    Paths = [{"/hello/:user/:typ/[:from]/[:to]", hello_handler, ?NO_OPTIONS = []},
             {"/chat/[:user]", cowboy_static, {priv_file, hello_erlang, "static/chatroom.html"}},
             {"/", cowboy_static, {priv_file, hello_erlang, "static/login.html"}},
             {"/login/post", login_handler, ?NO_OPTIONS},
             %{"/chunked_form", chunked_handler, ?NO_OPTIONS},
             %{"/constraints/:anything", constraints_handler, {constraints_met, true}},
             %{"/constraints/:an_int/:three_chars/[:add_one]", Constraints, constraints_handler, {constraints_met, true}},
             %{"/constraints/[...]", constraints_handler, {constraints_met, false}},
             {"/ws", chatws_handler, ?NO_OPTIONS},
             %{"/animate", animate_ws_handler, ?NO_OPTIONS}
             {"/[...]", cowboy_static, {priv_dir, hello_erlang, "static"}}
             ],

    Routes = [{?ANY_HOST, Paths}],
              %{"[...]", [{"/hpi/[...]", host_path_info_handler, ?NO_OPTIONS}]}],
    %[...] in the host spec must be in a string
    %[...] in the path spec must follow a slash

    Dispatch = cowboy_router:compile(Routes),
    _ = cowboy:start_http(my_http_listener, 100, [{port, 8080}], [{env, [{dispatch, Dispatch}]}]),
    hello_erlang_sup:start_link().


stop(_State) ->
	ok.
