-module(exam).
-export([first_n_abundant_nums/1, helper_for_abundant_num/4, sum_of_divisors/1, bin_to_decimal/1, numbers_from_n/2]).

first_n_abundant_nums(Num) ->
	helper_for_abundant_num(Num, 1, [], 2).

helper_for_abundant_num(Num, N, List, Acc) ->
	Sum = sum_of_divisors(Acc),
	if
	   N =< Num ->
	       if
		  Sum > Acc ->
	          Inc = N + 1,
		  HelperList = List ++ [Acc],
		  NextNum = Acc + 1,
		  helper_for_abundant_num(Num, Inc, HelperList, NextNum);
		true ->
		  NextNum = Acc + 1,
		  helper_for_abundant_num(Num, N, List, NextNum)
		end;
 	    true ->
	        List
	end.

sum_of_divisors(Num) ->
	Divisors = [N || N <- lists:seq(1, Num-1), Num rem N == 0],
	lists:sum(Divisors).

bin_to_decimal(List) ->
	helper_for_bin2dec(List, 0).


helper_for_bin2dec([], _) -> 0;
helper_for_bin2dec([H|[]], Acc) ->
	Sum = Acc + H * math:pow(2, 0);
	
helper_for_bin2dec([H|T], Acc) ->
	Power = length(T),
	Sum = Acc + H * math:pow(2, Power),
	helper_for_bin2dec(T, Sum).


numbers_from_n(N, M) ->
	helper_for_num(N, M, 0, [], 0).


helper_for_num(N, M, Acc, List, OldNum) ->
	if
	  Acc < M ->
	      NewNum = round(N * math:pow(10, Acc)),
	      Inc = Acc + 1,
	      Results = List ++ [NewNum + OldNum],	      
	      helper_for_num(N, M, Inc,Results, NewNum+OldNum);
	  true ->
	       List
	end.