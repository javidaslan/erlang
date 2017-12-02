-module(dc).
-export([opmap3/2, dcfib2/2, dc/2, basefib/1, is_basefib/1, sfib/1]).



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

dividefib(X) -> 
    [X-1, X-2].

combinefib(X) -> %% [X1, X2] 
    lists:sum(X). %% X1 + X2

is_basefib(X) ->
    X < 30. %%(X == 1) orelse (X == 0).

basefib(X) ->
    sfib(X).

dcfib2(N, Max) ->
    dc({fun is_basefib/1, 
	fun basefib/1, 
	fun dividefib/1,
	fun combinefib/1,
        N}, {Max, fun sfib/1}).


dc({IsBase, Base, Divide, Combine, Problem}, {Max, Sequential}) ->
    dc_helper({IsBase, Base, Divide, Combine, Problem}, {Max, Sequential}, 0).



dc_helper({IsBase, Base, Divide, Combine, Problem}, {Max, Sequential}, Counter) ->
    case IsBase(Problem) of
	true ->
	    Base(Problem);  
	false ->
	    SubProblems = Divide(Problem),
        Num_of_processes = Counter + length(SubProblems),
        if
            Max >= Num_of_processes ->
                SubSolutions = opmap3(fun(P) -> 
                    dc_helper({IsBase, Base, Divide, Combine, P}, {Max, Sequential}, Num_of_processes)
                end, SubProblems),
                Combine(SubSolutions);
            true ->
                Sequential(Problem)
        end
	    
    end.