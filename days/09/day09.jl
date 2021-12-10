using SparseArrays
using LinearAlgebra

stack(x) = copy(transpose(hcat(x...)))
reindex((i,j), m) = (j .- 1) .* m .+ i

function parse_input(input_src)
    return stack([
        map(x -> parse(Int, x), split(x, "")) for x in readlines(input_src)
    ])
end

function pad(mat::Matrix{Int64}, padding::Int64, fill_value::Int64)
    m, n = size(mat)
    padded = ones(m + 2 * padding, n + 2 * padding) * fill_value

    padded[1+padding:padding+m, 1+padding:padding+n] .= mat

    return padded

end

function compute_delta(mat::Matrix{Int64}, padding::Int64, fill_value::Int64)
    padded = pad(mat, padding, fill_value)

    #deltas = zeros(size(grid))
    #check above
    du = sign.(mat - padded[1:end-2, 2:end-1])
    #check below
    dd = sign.(mat - padded[3:end, 2:end-1])
    #check left
    dl = sign.(mat - padded[2:end-1, 1:end-2])
    #check right
    dr = sign.(mat - padded[2:end-1, 3:end])

    return du, dd, dl, dr
end

function find_seeds(grid::Matrix{Int64}, padding::Int64, fill_value::Int64)
    du, dd, dl, dr = compute_delta(grid, padding, fill_value)
    deltas = du + dd + dl + dr

    return findall(deltas .== -4)
end

function split_cartesian(indices::Vector{CartesianIndex{2}})
    r = map(x -> x[1], indices)[:, 1]
    c = map(x -> x[2], indices)[:, 1]
    
    return r,c
end

function encode(indices::Vector{CartesianIndex{2}}, shape::Tuple{Int64, Int64})
    m, n = shape
    r, c = split_cartesian(indices)
    I = reindex((r,c), m)
    
    v = zeros(Int64, m * n)
    v[I] .= 1
    
    return v
end

function decode(v::Vector, shape::Tuple{Int64, Int64})
    m, n = shape
    
    I = findall(v .≠ 0)
    
    c = Int.(floor.((I .- 1) ./ m)) .+ 1
    r = Int.((I .- 1) .% m) .+ 1
    
    return CartesianIndex.(r, c)
end


function delta2pairs(delta::Matrix{Float64}, lbl::Matrix{Int64}, tar::Int64)
    I = lbl[delta .< 0]
    J = I .+ tar
    return I, J
end

function grid2adj(grid::Matrix{Int64}, padding::Int64, fill_value::Int64)
    m,n = size(grid)
    lbl = reshape(collect(1:reduce(*, size(grid))), size(grid))
    
    du, dd, dl, dr = compute_delta(grid, padding, fill_value)
    
    #up/down change along rows (+/-1)
    Iu, Ju = delta2pairs(du[2:end, :], lbl[2:end, :], -1)
    Id, Jd = delta2pairs(dd[1:end-1, :], lbl[1:end-1, :], 1)
    #left/right change along columns (+/-m)
    Il, Jl = delta2pairs(dl[:, 2:end], lbl[:, 2:end], -m)
    Ir, Jr = delta2pairs(dr[:, 1:end-1], lbl[:, 1:end-1], m)
    
    I = vcat(Iu,Id,Il,Ir)
    J = vcat(Ju,Jd,Jl,Jr)
    V = ones(Int, length(I))
    
    return sparse(J, I, V, m*n, m*n)
end

function basin_size(
        Emap::SparseMatrixCSC{Int64, Int64}, 
        grid::Matrix{Int64}, 
        seed::CartesianIndex
    )

    #Encode the starting point as a vector
    v = encode([seed], size(grid))

    #Find the equilibrium vector
    #This contains a 1 for all points reachable from the seed
    vp = Emap * v
    #The length of the non-zero components of this vector
    #
    return length(findall(vp .≠ 0))
end

grid = parse_input("input.txt")
m,n = size(grid)
seeds = find_seeds(grid, 1, 100)

println("sum of risk levels: $(length(seeds) + sum(grid[seeds]))")

#Construct the adjacency matrix for the transition graph
#Points can only transition to other points if they are at a higher level
#Because 9's will not be included in the basin of attraction, we ignore them
#in this construction process
grid[grid .== 9] .= -1
A = grid2adj(grid, 1, 100)
#The equilibria map describes the long-time transitions that are possible from
#an initial seed.  The set of points that are reachable from the seed form the
#connected component to which the seed belongs.  Intutively, this forms the
#basin of attraction for the low point.
Emap = (I + A)^(m*n)
sizes = [basin_size(Emap, grid, s) for s in seeds]

println("basin product: $(reduce(*, sort(sizes)[end - 2:end]))")



