-module(drug_cartel).
-export([warehouse/0, guard/2, init_bad_guy/1]).


warehouse() ->
    Right_password = open_sesame,
    Wrong_password = open_barley,
    register(guard, spawn(?MODULE, guard, [[], Right_password])),
    [spawn(?MODULE, init_bad_guy, [Right_password]) || _ <- lists:seq(1,3)],
    [spawn(?MODULE, init_bad_guy, [Wrong_password]) || _ <- lists:seq(1,4)],
    timer:sleep(1000),
    fbi().


init_bad_guy(Password) ->
    guard ! {let_in, self()},
    bad_guy(Password).


guard(Users, Password) ->
    receive
        {let_in, Who} ->
            io:format("Wait...somebody is here, hey what is the password? ~p~n", [Who]),
            Who ! whats_the_password,
            guard(Users, Password);
        {password, PasswordFromWho, Who} ->
            if
                Password == PasswordFromWho ->
                    io:format("Come in dude! ~p~n", [Who]),
                    NewUsers = Users ++ [Who],
                    Who ! come_in,
                    guard(NewUsers, Password);                    
                true ->
                    io:format("Go away if you don't want problems! ~p~n", [Who]),
                    Who ! go_away,
                    guard(Users, Password)
            end;
        im_a_cop ->
            io:format("Damn! Cops are here ~n"),
            [Guy ! cops_are_here || Guy <- Users]
    end.


bad_guy(Password) -> 
    receive
        whats_the_password ->
            io:format("Password is: ~p~n", [{Password, self()}]),
            guard ! {password, Password, self()},
            bad_guy(Password);
        come_in ->
            bad_guy(Password);
        cops_are_here -> 
            io:format("I'm outta here! ~p~n", [self()]);
        go_away ->
            io:format("Guard didn't let me in.~p~n", [self()])
    end.

fbi() ->
    guard ! {let_in, self()},
    receive
        whats_the_password ->
            io:format("I'm a cop! ~p~n", [self()]),
            guard ! im_a_cop
    end.
            
