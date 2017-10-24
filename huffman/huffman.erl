-module(huffman).
-export([build_code_table/1, encode/1, decode/1]).


findFrequency(Elm, List) ->
    lists:sum([1 || X <- List, X == Elm]).


compress(Str) ->
    lists:usort([{findFrequency(X, Str), [X]} || X <- Str]).

update_queue(Str, HuffmanTree) ->
    {First_freq, First_node} = lists:nth(1, Str),
    {Second_freq, Second_node} = lists:nth(2, Str),
    if
        length(Str) > 1 ->
            Queue1 = lists:delete({First_freq, First_node}, Str),
            Queue2 = lists:delete({Second_freq, Second_node}, Queue1),
            Queue3 = lists:usort(Queue2 ++ [{First_freq+Second_freq, First_node++Second_node}]),
            HF1 = HuffmanTree ++ [{First_node++Second_node, First_node, 0}],
            %[io:format("Printing HF1: ~p ~n", [X]) || X <- HF1],
            HF2 = HF1 ++ [{First_node++Second_node, Second_node,1}],
            %[io:format("Printing HF2: ~p ~n", [X]) || X <- HF2],
            if
                length(Queue3) > 1 ->
                    update_queue(Queue3, HF2);
                true ->
                    HF2
            end           
    end.
    
build_code_table(Str) ->
    HuffmanTree = update_queue(compress(Str), []),
    Tree = traverse(HuffmanTree, []),
    [{Char, Code} || {Char, Code} <- Tree, length(Char) == 1].

traverse([], Acc) -> Acc;

traverse(HuffmanTree, Acc) ->
    {Root, Leaf, Label} = lists:nth(1,HuffmanTree),
    List = Acc ++ [findAllKeys(HuffmanTree,{Root, Leaf, Label}, [{Root, Leaf, Label}])],
    traverse(lists:delete({Root, Leaf, Label}, HuffmanTree), List).

findAllKeys(HuffmanTree, {Root, _, _}, Acc) ->
    Tuple = lists:keyfind(Root, 2, HuffmanTree),
    if 
        Tuple == false  ->
            {_, AccLeaf, _} = lists:nth(1,Acc),
            build_table(AccLeaf, Acc, []);
        true ->
            {SRoot, SLeaf, SLabel} = Tuple,
            SaveList = Acc ++ [{SRoot, SLeaf, SLabel}],
            findAllKeys(HuffmanTree, {SRoot, SLeaf, SLabel}, SaveList)
    end.


build_table(Char, [], Acc) ->
    {Char, lists:reverse(Acc)};

build_table(Char, List, Acc) ->
    {Root, Leaf, Label} = lists:nth(1,List),
    BinaryCode = Acc ++ integer_to_list(Label),
    build_table(Char, lists:delete({Root, Leaf, Label}, List), BinaryCode).
    

encode(Str) ->
    HuffmanTree = build_code_table(Str),
    encode_char(Str, HuffmanTree, []).

encode_char([], HuffmanTree, Acc) -> {HuffmanTree, Acc};

encode_char(Str, HuffmanTree, Acc) ->
    Char = lists:nth(1, Str),
    {_, Code} = lists:keyfind([Char], 1, HuffmanTree),
    BinaryString = Acc ++ Code,
    encode_char(lists:delete(Char, Str), HuffmanTree, BinaryString). 


decode({HuffmanTree, BinarySentence}) ->
    decode_helper({HuffmanTree, BinarySentence}, 1, []).
    

decode_helper({_, []}, _, Acc) -> Acc;

decode_helper({HuffmanTree, BinarySentence}, Nth, Acc) ->
    Head = lists:sublist(BinarySentence, Nth),
    Tail = lists:nthtail(Nth, BinarySentence),
    Tuple = lists:keyfind(Head, 2, HuffmanTree),
    if
        Tuple /= false ->
            {Char, _} = Tuple,
            DecodedString = Acc ++ Char,
            decode_helper({HuffmanTree, Tail}, 1, DecodedString);
        true ->
            NextN = Nth + 1,
            decode_helper({HuffmanTree, BinarySentence}, NextN, Acc)
    end.


