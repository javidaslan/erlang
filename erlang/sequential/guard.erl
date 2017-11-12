-module(guard).
-export([factorial/1, guard/2]).


factorial(N)
    when N > 0 -> N * factorial(N-1);
factorial(0) -> 1.


% , - is AND, ; - is OR
guard(N, M) when N > 5, M < 5 -> N * M;
guard(N, M) when N =< 5; M >= 5 -> N + M.

% Git check %
