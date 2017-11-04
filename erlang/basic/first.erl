-module(first).

-export([]). % TODO: proper export

-compile(export_all).

f() ->
    ok.

%% Example function for extracting the first element of a two- and three-tuple
%% Partial function
fst({A, _B}) ->
    A;
fst({A, _, _}) ->
    A.
%fst(_) ->
%   ok.

%% Checking equality (considering the type too)
eq(A, B) ->
    A =:= B;
eq(_,_) ->
    false.

%% The same functionality with patternmatching
eq_(A, A) ->
    true;
eq_(_,_) ->
    false.

%% Functions local to the module can be used without module qualifier
%% Only the exported functions can be qualified
g() ->
    eq(1,2).
    


