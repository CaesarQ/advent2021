using DelimitedFiles

#Initial [horizontal_pos, depth]
initial_pos = zeros(Int, 1,2)

# Load data
data = readdlm("input.txt", ' ', String, '\n');

commands_given = data[:, 1]
deltas = map(x -> parse(Int, x), data[:, 2])

command2id = ["forward", "down", "up"]
id2displacement = [1 0; 0 1; 0 -1]

commands_id = transpose(command2id .== permutedims(commands_given))

coord_delta = (commands_id * id2displacement) .* deltas
net_displacement = initial_pos + sum(coord_delta, dims=1)

println("net displacement (pos, depth): $(net_displacement)")

puzzle_answer = net_displacement[1] * net_displacement[2]
println("product of horizontal position and depth: $(puzzle_answer)")
