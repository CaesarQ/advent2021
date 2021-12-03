using DelimitedFiles
using LinearAlgebra

# Load data
data = readdlm("input.txt", ' ', String, '\n');

commands_given = data[:, 1]
deltas = map(x -> parse(Int, x), data[:, 2])

#=
h: horizontal position
d: depth
a : aim

Represent the state of the system as follows: [h, d, a, 1]

A representation for "forward x" is then a linear transform:
h -> h' = F_x * h, where
F_x = [1 0 0 x; 0 1 x 0; 0 0 1 0; 0 0 0 1] = I + xf
Here f denotes the generator of the transform F_x

Similary, letting D_x and U_x denote "down x" and "up x" respectively:

D_x = [1 0 0 0; 0 1 0 0; 0 0 1 x; 0 0 0 1] = I + xd
U_x = [1 0 0 0; 0 1 0 0; 0 0 1 -x; 0 0 0 1] = I + xu

Where once again, d and u denote the generators of the respective transform.

The final transformation will be given a product of the sequence of matrices
corresponding to the sequence of commands given.

=#

#Initial [horizontal_pos, depth, aim, buffer]
initial_pos = [0; 0; 0; 1]

f = [0 0 0 1; 0 0 1 0; 0 0 0 0; 0 0 0 0]
d = [0 0 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0]
u = [0 0 0 0; 0 0 0 0; 0 0 0 -1; 0 0 0 0]

cmap = Dict([("forward", f), ("down", d), ("up", u)])
generators = map(x -> cmap[x], commands_given)

#construct the transforms from the generators and the parameters
transforms = map(x -> I + x[1] * x[2], zip(deltas, generators))

#while we have collected the transforms as follows [t1 t2 ... tN]
#we must operate on the initial state as follows: tN(...(t2(t1(initial_state))))
final_state = reduce(*, reverse(transforms)) * initial_pos

println("final state (pos, depth, aim): $(final_state[1:end-1])")
puzzle_answer = final_state[1] * final_state[2]
println("product of horizontal position and depth: $(puzzle_answer)")