-module(assign).

-export([fib/1, parmapn/3, dispatcher/3, collector/2, worker/2]).

fib(0) ->
    1;
fib(1) ->
    1;
fib(N) when N > 1 ->
    fib(N-1) + fib(N-2).


dispatcher(Pids, F, List) ->
    Parent = self(),
    First_n_element = lists:sublist(List, length(Pids)),
    Rest_of_list = lists:sublist(List, length(Pids)+1, length(List)),
    Pairs = lists:zip(First_n_element, Pids),
    [Pid ! {Data, F, Parent} || {Data, Pid} <- Pairs], %initiate process
    [receive
        {done, Pid} -> 
            Pid ! {Next_element, F, Parent}
    end || Next_element <- Rest_of_list],
    exit(normal).


collector(List, Parent_pid) ->
    Results =  [receive
        {Elm, Result} -> Result
        end || Elm <- List],
    Parent_pid ! Results,
    exit(normal).


worker(Num_of_elements, Collector_pid) ->  
    [receive
        {Data, F, Parent_pid} ->
            Collector_pid ! {Data, F(Data)},
            Parent_pid ! {done, self()}
    end || _ <- lists:seq(1, Num_of_elements)].


parmapn(N, F, List) ->
    Parent = self(),
    Num_of_elements = length(List),
    Num_of_processes = min(N, Num_of_elements),
    Collector_pid = spawn(?MODULE, collector, [List, Parent]),
    Workers = [spawn(?MODULE, worker, [Num_of_elements, Collector_pid]) || _ <- lists:seq(1, Num_of_processes)],
    spawn(?MODULE, dispatcher, [Workers, F, List]),
    [exit(Pid, normal) || Pid <- Workers],
    receive
        Results ->
            Results
    end.
    