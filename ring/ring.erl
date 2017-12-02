-module(ring).
-export([start/0, worker/1]).



start() ->
    Processes = [a,b,c,d,e],
    fun(X) ->
        create_processes(Processes, self()),
        if 
            X == quit ->
                a ! quit;
            true ->
                a ! {forward, X}
        end,
        receive
            {forward, N} ->
                N;
            quit ->
                quit
        end
    end.
    


worker(Successor) ->    
    receive
        {forward, N} -> 
            Successor ! {forward, N+1};
        quit ->
            Successor ! quit
    end. 

create_processes([X | []], Parent) -> 
    register(X, spawn(?MODULE, worker, [Parent]));

create_processes(Processes, Parent) ->
    [X | Xs] = Processes,
    register(X, spawn(?MODULE, worker, [lists:nth(1, Xs)])),
    create_processes(Xs, Parent).
    