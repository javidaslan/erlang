-module(chat).
%% Server interface
-export([start/0, f/2]).

-define(M, ?MODULE).
-define(srv, chat_server).
-define(srv(), chat).
-define(srv(A), A ++ atom_to_list(?srv())++ atom_to_list(?srv) ++ ??A ++ A).
-define(name, f().
-define(arg, A,B)).
-define(arrow,->).
-define(body, ok).

%% Client interface
-export([]).

-record(state, {users = [], log = ""}).
-record(user, {pid, nick}).
?name?arg?arrow?body.

%% Server functions
start()->
    %A = "apple",
    %?srv(A). %% A ++ atom_to_list(?srv())++ atom_to_list(?srv) ++ ??A ++ "apple")
    register(?srv, spawn(?MODULE, init, [])).

init() ->
    process_flag(trap_exit, true),
    State = #state{}, %users=[]}.
    loop(State).

loop(St=#state{users=U})->
    receive
	stop ->
	    ok;
	{log_in, Pid, Nick} ->
	    NewU = [#user{pid= Pid, nick = Nick} |U],
	    loop(St#state{users=NewU});
	{text, Pid, Msg} ->
	    %U = St#state.users
	    lists:foreach(fun(#user{pid=P}) -> P ! {msg, Msg} end,  U),
	    loop(St);
	{log_out, Pid} ->
	    loop(ok);
	{'EXIT', _, _} ->
	    loop(ok)
    end.
