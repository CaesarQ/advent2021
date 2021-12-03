using DelimitedFiles

# Load data
input = readdlm("input.txt", ' ', String, '\n');

#convert the matrix of binary strings into a matrix of ints
#treating each bit as a separate int
data = copy(transpose(
    hcat(map(x -> map(y -> parse(Int, y), collect(x)), input)...)
))
n_string, n_bit = size(data)
power_string = reverse(2 .^ (0:n_bit-1))

#The bits are either 1's or 0's
#As such, we can count the number of 1's by taking the sum along the rows
#If this sum is greater than half the number of rows, the 1's have a
#majority.  Else, the majority will be 0.
gamma_rate_string = dropdims(Int.(sum(data, dims=1) .> n_string / 2), dims=1)
#Since the bits are either 1's or 0's, if the majority bit is a 1,
#the minority bit is a 0, and vice versa.
epsilon_rate_string = 1 .- gamma_rate_string

#in this representation, we can convert binary string to decimal using the
#dot product with the power string

gamma_rate_dec = sum(power_string .* gamma_rate_string)
epsilon_rate_dec = sum(power_string .* epsilon_rate_string)

power_consumption = gamma_rate_dec * epsilon_rate_dec

println("The submarine is consuming $(power_consumption) units of power")


println(typeof(data))