-module(parcomp).

-compile(export_all).

smap(F, L) ->
    [F(H) || H <- L].
    %%[apply(F, [H]) || H <- L].

pmap(F, L) ->
    Parent = self(),
    [spawn(fun() ->  Parent ! F(H) end) || H <- L],
    [receive 
	 Res -> Res
     end || _ <- L].

pmap2(F, L) ->
    Parent = self(),
    [receive 
	 Res -> Res
     end || _ <- [spawn(fun() ->  Parent ! F(H) end) || H <- L]].

opmap1(F, L) ->
    Parent = self(),
    Index = lists:seq(1, length(L)),
    NewList = lists:zip(Index, L),
    io:format("NewList: ~p~n", [NewList]),
    [spawn(fun() ->  Parent ! {I, F(H)} end) || {I, H} <- NewList],
    [receive 
	 {I, Res} -> Res
     end || I <- Index].

opmap2(F, L) ->
    Parent = self(),
    [spawn(fun() ->  Parent ! {H, F(H)} end) || H <- L],
    [receive 
	 {I, Res} -> Res
     end || I <- L].

opmap3(F, L) ->
    Parent = self(),
    Pids = [spawn(fun() ->  Parent ! {self(), F(H)} end) || H <- L],
    [receive 
	 {I, Res} -> Res
     end || I <- Pids].

sfib(0) ->
    1;
sfib(1) ->
    1;
sfib(N) when N > 1->
    sfib(N-1) + sfib(N-2).

dcfib(N) ->
    case is_basefib(N) of
	true ->
	    basefib(N);  
	false ->
	    SubProblems = dividefib(N),
	    SubSolutions = smap(fun dcfib/1, SubProblems),
	    combinefib(SubSolutions)
    end.

is_basefib(X) ->
    (X == 1) orelse (X == 0).

basefib(_) ->
    1.

dividefib(X) -> 
    [X-1, X-2].

combinefib(X) -> %% [X1, X2] 
    lists:sum(X). %% X1 + X2

dcfib2(N) ->
    dc({fun s/1, 
	fun basefib/1, 
	fun dividefib/1,
	fun combinefib/1,
        N}).

qs([])->
    [];
qs([H | T])->
    {SP1, SP2} = lists:partition(fun(X) -> X < H end, T),
    qs(SP1) ++ [H] ++ qs(SP2).

dc({IsBase, Base, Divide, Combine, Problem}) ->
    case IsBase(Problem) of
	true ->
	    Base(Problem);  
	false ->
	    SubProblems = Divide(Problem),
	    SubSolutions = lists:map(fun(P) -> 
			      dc({IsBase, Base, Divide, Combine, P})
				 end, SubProblems),
%% [dc({IsBase, Base, Divide, Combine, P}) || P <- SubProblems ]
	    Combine(SubSolutions)
    end.
