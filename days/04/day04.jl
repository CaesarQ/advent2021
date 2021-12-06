function card2matrix(card::AbstractString)
    new_card = replace(card, "\n" => " ")
    new_card = replace(new_card, "  " => " ")
    int_list = filter(x -> ~isempty(x), split(new_card, " "))
    return copy(transpose(reshape(parse.(Int, int_list), (5,5))))
end

function run_bingo(matrices::Array{Int64, 3}, numbers::Vector{Int64}, mode::String)
    @assert mode in ["first", "last"]
    mask = zeros(Int, size(matrices))
    not_won = ones(Bool, size(matrices)[1])

    #The turn in which the card was won
    turn_won = zeros(Int, size(matrices)[1])


    for (i, number) in enumerate(numbers)
        #println(not_won)
        if sum(not_won) == 0
            break
        end

        #mark the bingo numbers for cards that have not won
        mask[(matrices .== number) .& not_won] .= 1

        #check rows and columns for winners
        row_wins = any(sum(mask[not_won, :, :], dims=2)[:, 1, :] .== 5, dims=2)[:, 1]
        col_wins = any(sum(mask[not_won, :, :], dims=3)[:, :, 1] .== 5, dims=2)[:, 1]
        winners = findall(row_wins .|| col_wins)
        
        
        if size(winners)[1] != 0
            if mode == "first"
                winner = winners[1]
                return (number, matrices[not_won, :, :][winner, :, :], mask[not_won, :, :][winner, :, :])
            end
            
            inds_to_update = findall(not_won)[winners]
            not_won[inds_to_update] .= false
            turn_won[inds_to_update] .= i

        end
    end

    last_turn, last_winner = findmax(turn_won)
    number = numbers[last_turn]

    return number, matrices[last_winner, :, :], mask[last_winner, :, :]
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

first_card_score = score_card(run_bingo(matrices, numbers, "first")...)
last_card_score = score_card(run_bingo(matrices, numbers, "last")...)

println("Puzzle answer #1: $(first_card_score)")
println("Puzzle answer #2: $(last_card_score)")