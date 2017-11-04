-module(recursion).
-import(io,[fwrite/1]).
-export([sum/1, lengthR/1, area/1, fib/1, maxL/1, swedish_date/0]).

today() -> tuple_to_list(date()).

convertToSwedish([]) ->
    [];
convertToSwedish([X|Xs]) ->
    [integer_to_list(X)|convertToSwedish(Xs)].

swedish_date() ->
    lists:concat(lists:reverse(convertToSwedish(today()))).

sum([]) ->
    0;
sum([X|Xs]) ->
    X + sum(Xs).

lengthR([]) ->
    0;
lengthR([_|Xs]) ->
    1 + length(Xs).

area({square, Side}) ->
    Side * Side ;
area({circle, Radius}) ->
    math:pi() * Radius * Radius;
area({triangle, A, B, C}) ->
    S = (A + B + C)/2,
    math:sqrt(S*(S-A)*(S-B)*(S-C));
area(Other) ->
    {error, invalid_object}.

fib(0) ->
    0;
fib(1) ->
    1;
fib(N) ->
    fib(N-1) + fib(N-2).


maxL([]) -> empty_list;
maxL([H|T]) -> maxHelper(H, T).

maxHelper(X, []) -> X;
maxHelper(X, [H|T]) when X < H -> maxHelper(H, T);
maxHelper(X, [_|T]) -> maxHelper(X, T).

