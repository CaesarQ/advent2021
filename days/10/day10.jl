char_list = [')', ']', '}', '>']
char_map = Dict('('=>')', '['=>']', '{'=>'}', '<'=>'>')
close_brackets(s::String) = map(x -> char_map[x], reverse(s))

str2array(x) = only.(split(x, ""))

corrupt_char_dict = Dict(' '=> 0, ')'=>3, ']'=>57, '}'=>1197, '>'=>25137)
incomplete_char_dict = Dict(' '=> 0, ')'=>1, ']'=>2, '}'=>3, '>'=>4)
score_corrupt_char(x::Char) = corrupt_score_dict[x]
score_incomplete_char(x::Char) = incomplete_char_dict[x]

function iterative_replace(s::String)
    new_s = replace(s, "<>"=>"")
    new_s = replace(new_s, "[]"=>"")
    new_s = replace(new_s, "{}"=>"")
    new_s = replace(new_s, "()"=>"")
    
    return new_s
end

function remove_pairs(s::String)
    while s ≠ iterative_replace(s)
        s = iterative_replace(s)
    end
    
    return s
end

function find_end_bracket(s::String) 
    loc = findfirst(y -> y in "}])>", s)
    return isnothing(loc) ? ' ' : s[loc]
end

corruption_score(s::String) = s |> remove_pairs |> find_end_bracket |> score_incomplete_char

function incomplete_score(s::String)
    remainder = s |> remove_pairs |> close_brackets
    char_scores = score_incomplete_char.(str2array(remainder))
    powers = 5 .^collect(length(char_scores)-1:-1:0)
    return sum(powers .* char_scores)
end

function median(x::Vector{Int64})
    sorted = sort(x)
    N = length(x)

    if N %2 == 1
        return sorted[Int(floor(N/2)) + 1]
    else
        return sorted[Int(floor(N/2))]
    end
end

input_src = "input.txt"
lines = readlines(input_src)

c_scores = corruption_score.(lines)

println("Total syntax error score: $(sum(c_scores))")

incomplete = lines[c_scores .== 0]

i_scores = incomplete_score.(incomplete)

println("Median completion scores: $(median(i_scores))")

