using DelimitedFiles

#=
|--------------------A NEAT TRICK------------------------------------------|
signals is a list of the randomly permuted segments of each digit, presented 
in a random order.  However, we can still use this to decode one of the
output digits, without necessarily having to learn the permutation itself.

For a given digit, we simply count how many times each segment 
appears in the signal list.  This gives a unique value to each digit that is
invariant under permutations.

Let us construct an encoder matrix, whose rows are the segments, and whose 
columns are the digits.  The matrix contains a '1' when a segment is used in a 
particular digit, and a '0' when it is not.  Call this matrix E.  Then the 
following vector is covvariant under permutations P:

v = E^T E|1>
v -> v' = Pv

We can then determine P using elementwise comparisons as P = (v .== v)

=#

E = readdlm("encoder.txt", ',', Int, '\n')
unique_num = sum(transpose(E) * E, dims=1)[1, :]
mapping = Dict(unique_num .=> 0:9)

occurences(str1, str2) = sum([str1...].∈str2)

function decode(line)
    segments, output = split(line, " | ")
    return ["$(mapping[occurences(segments, o)])" for o in split(output)] |> join
end

outputs = map(decode, readlines("input.txt"))

search_str = "1478"
counts = sum(map(x -> occurences(x, search_str), outputs))

println("Numer of times (1,4,7,8) appears: $(counts)")
println("Sum of outputs: $(sum(map(x -> parse(Int, x), outputs)))")