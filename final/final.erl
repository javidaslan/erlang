-module(final).
-export([pmap_on_chunks/3, worker/3]).

%Server interface
-export([start/0, server_status/0,stop/0,webshop/1, replenish/1, items_in_stock/0, item_list/0]).

%Client interface
-export([available_items/0, order_item/1,customer/1,impulse_buyers/1]).

pmap_on_chunks(F, L, N) ->
	Groups = divide_list(L, N, []),
	[spawn(?MODULE, worker, [F, Group, self()]) || Group <- Groups],
	lists:merge([receive
		{Group, Res} ->
			Res
	end || Group <- Groups]).


worker(F, Group, Pid) ->
	  Results = lists:map(F, Group),
	  Pid ! {Group, Results}.
	  

divide_list([], _, Groups) -> lists:reverse(Groups);

divide_list(L, N, Groups) ->
	{NewGroup,RestOfList} = lists:split(N, L),
	divide_list(RestOfList, N, [NewGroup|Groups]).


server_status() ->
	Status = whereis(webshop),
	if
	   Status == undefined ->
	   	offline;
	   true -> online
	end.

start() ->
	Status = server_status(),
	if
	   Status == offline ->
	   	  register(webshop, spawn(?MODULE, webshop, [[]])),
		  io:format("Server started~n"),
		  ok;
	   true ->
	   	ok
	end.

stop() ->
       Status = server_status(),
       if
	   Status == offline ->
		  io:format("Server is offline~n"),
		  ok;
	   true ->
	   	webshop ! stop
	end.

replenish(NewProducts) ->
	webshop ! {new_products, NewProducts}.

items_in_stock() ->
	webshop ! list_products.

webshop(Products) ->
	receive
		{new_products, NewProducts} ->
			io:format("New products will be added: ~p~n",[NewProducts]),
			webshop(lists:merge(NewProducts, Products));
		stop ->
		     io:format("Stopping~n"),
		     ok;
		list_products ->
			io:format("Available products: ~p~n", [Products]),
			webshop(Products);
		{customer_wants_list, Customer} ->
			Customer ! {here_it_is, lists:usort(Products)},
			webshop(Products);
		{order_item, Item, Customer} ->
			     ItemFound = lists:member(Item, Products),
			     if
				ItemFound ->
					  Customer ! order_accepted,
					  webshop(lists:delete(Item, Products));
				true ->
				     Customer ! order_declined,
				     webshop(Products)
			     end
	end.


available_items() ->
	webshop ! {customer_wants_list, self()},
	receive
		{here_it_is, Products} ->
			     Products
	after 2000 ->
	      server_unavailable
	end.

order_item(Item) ->
	webshop ! {order_item, Item, self()},
	receive
		order_accepted ->
			     Item;
		order_declined ->
			       order_declined
	after 2000 ->
	      server_unavailable
	end.

customer(0) -> io:format("I finished shopping :) ~n");
customer(N) ->
	AvailableItems = available_items(),
	if
	  length(AvailableItems) > 0 ->
	  	RandItem = lists:nth(rand:uniform(length(AvailableItems)), AvailableItems),
	  	Order = order_item(RandItem),
		if
		  Order == RandItem ->
		  	io:format("My order is accepted :)~p~n", [RandItem]),
			customer(N-1);
		  true ->
		       io:format("My order is declined :( ~p~n", [RandItem]),
		       customer(N)
		end;
	  true ->
	      io:format("Nothing to buy :( ~n")
	end.


impulse_buyers(L) ->
	lists:map(fun(N) -> spawn(?MODULE, customer, [N]) end, L).


item_list() ->
    [phone, fridge, oven, dishwasher, tv, pc, laptop, tablet, printer, food_processor].