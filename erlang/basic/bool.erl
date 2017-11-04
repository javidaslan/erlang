-module(bool).
-export([b_not/1, b_and/2, b_or/2]).


b_not(false) ->
    true;
b_not(true) ->
    false;
b_not(Other) ->
    error.

b_and(true, true) ->
    true;
b_and(_, _) -> 
    false.

b_or(false, false) ->
    false;
b_or(_, _) -> 
    true.