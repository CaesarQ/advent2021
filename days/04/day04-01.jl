function stack(array_list::Vector{Matrix})

end

function card2matrix(card::AbstractString)
    new_card = replace(card, "\n" => " ")
    new_card = replace(new_card, "  " => " ")
    int_list = filter(x -> ~isempty(x), split(new_card, " "))
    return copy(transpose(reshape(parse.(Int, int_list), (5,5))))
end

raw_input = open("input.txt") do file
    read(file, String)
end

data = split(raw_input, "\n\n")

numbers = parse.(Int, split(data[1], ","))

const newaxis = [CartesianIndex()]
matrices = vcat([card2matrix(c)[newaxis, :, :] for c in data[2:end]]...)

println(size(matrices))

display(matrices[1,:,:])
println()

display(matrices[end,:,:])
println()