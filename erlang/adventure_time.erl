-module(adventure_time).
-export([finn/1, jake/0, begin_adventure/0, stranger/1]).

finn(Jake_pid) ->
    Finn_pid = self(),
    io:format("Finn: What time is it?~n"),
    Jake_pid ! {what_time_is_it, Finn_pid},
    receive 
	    adventure_time -> 
            io:format("Finn: That's right buddy~n")
    end.

jake() ->
    receive
        {what_time_is_it, Pid} -> 
            io:format("Jake: Adventure time!~n"),
            Pid ! adventure_time
    end.

stranger(Finn_pid) ->
    io:format("Finn's pid~n"),
    Finn_pid ! 'I don\'t know'.

begin_adventure() ->
    Jake_pid = spawn(adventure_time, jake, []),
    spawn(adventure_time, finn, [Jake_pid]).
    %Finn_pid = spawn(adventure_time, finn, [Jake_pid]).
    %spawn(adventure_time, stranger, [Finn_pid]).
    

                
