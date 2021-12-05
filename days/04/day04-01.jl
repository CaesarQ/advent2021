

function card2matrix(card::AbstractString)
    new_card = replace(card, "\n" => " ")
    new_card = replace(new_card, "  " => " ")
    return reshape(parse.(Int, split(new_card, " ")), (5,5))
end

function encode_matrix(mat::Array{Int64})
    dict = Dict(
        "counts" => zeros(Int, 10)

    )
end

raw_input = open("input.txt") do file
    read(file, String)
end

data = split(raw_input, "\n\n")

numbers = parse.(Int, split(data[1], ","))
