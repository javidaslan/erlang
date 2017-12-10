-module(chat).
%% Server interface
-export([start/0, init/0, loop/1]).

-define(srv, chat_server).

-record(state, {users = [], log = "", max}).
-record(user, {pid, nick}).

-on_load(initload/0).

initload() ->
	io:format("jdghfdfd"),
	case whereis(?srv) of
		undefined -> ok;
		P -> P ! upgrade
	end.

%% Server functions
start()->
    register(?srv, spawn(?MODULE, init, [])).

init() ->
    process_flag(trap_exit, true),
    State = #state{}, 
    ?MODULE:loop(State).

loop(St=#state{users=U})-> %% St = {U, _, _}
    receive
	stop ->
	    io:format("~p", [St]);
	{log_in, Pid, Nick} ->
		case lists:filter(fun(#user{nick = N, pid = P}) -> 
							(N == Nick) orelse (P == Pid)
						  end, U) of
			[] ->
				if St#state.max == length(U) ->
						Pid ! deny,
						loop(St);
				   true ->
						NewU = [#user{pid= Pid, nick = Nick} |U],
						Pid ! ok,
						link(Pid),
						loop(St#state{users=NewU})
				end;
			_ ->
				Pid ! deny,
				loop(St)
		end;
	{text, Pid, Msg} ->
		[#user{nick = Nick}] =
			lists:filter(fun(#user{pid = P}) -> 
							(P == Pid)
						 end, U),
		NewMsg = Nick ++ ":   " ++ Msg,
	    lists:foreach(fun(#user{pid=P}) -> P ! {msg, NewMsg} end,  U),
	    loop(St);
	{log_out, Pid} ->
		NewU = lists:filter(fun(#user{pid = P}) -> 
								(P =/= Pid)
							end, U),
	    loop(St#state{users=NewU});
	{'EXIT', Pid, _} ->
		%self() ! {log_out, Pid},
		%loop(St)
		%?MODULE:loop(St)
	    NewU = lists:filter(fun(#user{pid = P}) -> 
								(P =/= Pid)
							end, U),
	    loop(St#state{users=NewU});
	upgrade ->
		% transform the state when needed
		?MODULE:loop(St)
    end.
