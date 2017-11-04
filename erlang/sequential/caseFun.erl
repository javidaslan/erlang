-module(caseFun).
-export([caseFun/1, safe/1, preferred/1]).


caseFun(Num) -> 
    List = [1,2,3,4,5,6],
    case lists:member(Num, List) of
        true -> ok;
        false -> {error, Num}
    end.

% This is unsafe because variable Y is defined in only one case clause
% and compiler won't let you compile module with "unsafe" variables
%unsafe(X) ->
%    case X of
%        one -> Y = 1;
%        two -> Z = 2;
%        _ -> T = other
%    end,
%    Y.

% This is safe because variable Y is defined in all case clauses
% but it is not preferred way.
safe(X) ->
    case X of
        one -> Y = 1;
        two -> Y = 2;
        _ -> Y = other
    end,
    Y.

% This is safe and preferred way
preferred(X) ->
    Y = case X of
            one -> 1;
            two -> 2;
            _ -> other
    end,
    Y.