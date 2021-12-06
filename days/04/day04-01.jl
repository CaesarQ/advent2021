function card2matrix(card::AbstractString)
    new_card = replace(card, "\n" => " ")
    new_card = replace(new_card, "  " => " ")
    int_list = filter(x -> ~isempty(x), split(new_card, " "))
    return copy(transpose(reshape(parse.(Int, int_list), (5,5))))
end

function find_first_bingo(matrices::Array{Int64, 3}, numbers::Vector{Int64})
    mask = zeros(Int, size(matrices))

    for number in numbers
        #mark the bingo numbers
        mask[matrices .== number] .= 1
    
        row_wins = any(sum(mask, dims=2)[:, 1, :] .== 5, dims=2)[:, 1]
        col_wins = any(sum(mask, dims=3)[:, :, 1] .== 5, dims=2)[:, 1]
    
        bingo = findfirst(row_wins .|| col_wins)
        
        if ~isnothing(bingo)
            return (number, matrices[bingo, :, :], mask[bingo, :, :])
        end
    
    end

    return -1
end

function score_card(bingo_number::Int, matrix::Matrix{Int64}, markers::Matrix{Int64})
    sum_unmarked = sum(matrix .* (1 .- markers))

    return bingo_number * sum_unmarked

end

raw_input = open("input.txt") do file
    read(file, String)
end

data = split(raw_input, "\n\n")

numbers = parse.(Int, split(data[1], ","))

const newaxis = [CartesianIndex()]
matrices = vcat([card2matrix(c)[newaxis, :, :] for c in data[2:end]]...)

winning_number, winning_card, mask = find_first_bingo(matrices, numbers)

println("Puzzle answer: $(score_card(winning_number, winning_card, mask))")