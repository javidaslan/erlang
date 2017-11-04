% First Erlan
-module(hello).
-import(io,[fwrite/1]).
-export([first/0, displayFloats/0, displayString/0]).

first() ->
    fwrite("Hello, World\n").

displayFloats() ->
    io:fwrite("~f~n",[1.1+1.2]), 
    io:fwrite("~e~n",[1.1+1.2]),
    io:fwrite("~w~n",[1.1+1.2]).

displayString() ->
    Str = "This is a string!",
    io:fwrite("~p~n", [Str]),
    io:fwrite([Str]).