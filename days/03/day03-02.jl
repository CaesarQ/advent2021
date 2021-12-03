using DelimitedFiles
using Statistics

# Load data
input = readdlm("input.txt", ' ', String, '\n');

#convert the matrix of binary strings into a matrix of ints
#treating each bit as a separate int
data = copy(transpose(
    hcat(map(x -> map(y -> parse(Int, y), collect(x)), input)...)
))


function decode_binary_string(binary_string::Vector{Int64})
    n_bit = length(binary_string)
    power_string = reverse(2 .^ (0:n_bit-1))

    return sum(power_string .* binary_string)
end

function get_rating(data::Matrix{Int64}, bit_id::Int64, mode::String)
    @assert mode in ["O2", "CO2"]

    n_string = size(data)[1]
    if n_string == 1
        return data
    end

    bit_check = convert(Int, sum(data[:, bit_id]) >= n_string / 2)

    if mode == "O2"
        #find the most common
        #in case of a tie, return 1
        nums_to_retain = data[:, bit_id] .== bit_check
    elseif mode == "CO2"
        #find least common
        #in case of a tie, return 0
        nums_to_retain = data[:, bit_id] .== (1 - bit_check)
    end

    #println(size(data))

    return get_rating(data[nums_to_retain, :], bit_id + 1, mode)

end


o2_rating = decode_binary_string(get_rating(data, 1, "O2")[1, :])
co2_rating = decode_binary_string(get_rating(data, 1, "CO2")[1, :])
println("Life support rating of the submarine: $(o2_rating * co2_rating)")