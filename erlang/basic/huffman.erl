-module(huffman).
-export([build_code_table/1, encode/1, decode/1, compress/1, update_queue/2]).


findFrequency(Elm, List) ->
    lists:sum([1 || X <- List, X == Elm]).


compress(Str) ->
    lists:usort([{findFrequency(X, Str), [X]} || X <- Str]).


update_queue([], HuffmanTree) ->
    HuffmanTree;

update_queue(Str, HuffmanTree) ->
    
    if
        length(Str) > 1 ->
            [{First_freq, First_node}|TailFromFirst] = Str,
            [{Second_freq, Second_node}|TailFromSecond] = TailFromFirst,
            Queue = TailFromSecond ++ [{First_freq+Second_freq, First_node++Second_node}],
            HF1 = HuffmanTree ++ [{First_node++Second_node, First_node, 0}],
            HF2 = HF1 ++ [{First_node++Second_node, Second_node,1}],
            if
                length(Queue) > 1 ->
                    update_queue(Queue, HF2);
                true ->
                    HF2
            end;
        true ->
            [{_, First_node}|_] = Str,
            HuffmanTree ++ [{First_node, First_node,1}]
                         
    end.
    
build_code_table(Str) ->
    HuffmanTree = update_queue(compress(Str), []),
    Tree = traverse(HuffmanTree, []),    
    [{Char, Code} || {Char, Code} <- Tree, length(Char) == 1].

traverse([], Acc) -> Acc;

traverse(HuffmanTree, Acc) ->
    [{Root, Leaf, Label} | Tail] = HuffmanTree,
    List = Acc ++ [findAllKeys(HuffmanTree,{Root, Leaf, Label}, [{Root, Leaf, Label}])],
    traverse(Tail, List).

findAllKeys([], _, Acc) -> Acc;

findAllKeys(HuffmanTree, {Root, Leaf, Label}, Acc) ->
    Tuple = lists:keyfind(Root, 2, HuffmanTree),
    if 
        Tuple == false  ->
            [{_, AccLeaf, _}|_] = Acc,
            build_table(AccLeaf, Acc, []);
        true ->
            {SRoot, SLeaf, SLabel} = Tuple,
            SaveList = Acc ++ [{SRoot, SLeaf, SLabel}],
            if
               {SRoot, SLeaf, SLabel} ==  {Root, Leaf, Label} ->
                   build_table(SLeaf, Acc, []);
                true ->
                    findAllKeys(HuffmanTree, {SRoot, SLeaf, SLabel}, SaveList)
            end
    end.


build_table(Char, [], Acc) ->
    {Char, lists:reverse(Acc)};

build_table(Char, List, Acc) ->
    [{_, _, Label}|T] = List,
    BinaryCode = Acc ++ integer_to_list(Label),
    build_table(Char, T, BinaryCode).

encode(Str) ->
    HuffmanTree = build_code_table(Str),
    encode_char(Str, HuffmanTree, []).

encode_char([], HuffmanTree, Acc) -> {HuffmanTree, Acc};

encode_char(Str, HuffmanTree, Acc) ->
    [Char|Tail] = Str,
    %Char = lists:nth(1, Str),
    {_, Code} = lists:keyfind([Char], 1, HuffmanTree),
    BinaryString = Acc ++ Code,
    encode_char(Tail, HuffmanTree, BinaryString). 


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


