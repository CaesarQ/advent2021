#Helper funcs
unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))
stack(x) = copy(transpose(hcat(x...)))
mat2set(mat) = Set([tuple(a...) for a in eachrow(mat)])
set2mat(s) = stack(collect.(collect.(s)))
all_pairs(l1,l2) = [(i,j) for i∈1:length(l1) for j∈1:length(l2)]

parse_line(x) = map(i -> parse(Int, i), split(x, ","))

const newaxis = [CartesianIndex()]
pairwise_diff(x::Matrix{Int64}) = x[:, :, newaxis] .- transpose(x)[newaxis, :, :]
pairwise_l1(x::Matrix{Int64}) = sum(abs.(pairwise_diff(x)), dims=2)[:, 1, :]


function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end
    
    coords = []
    for scanner in split(raw_input, "\n\n")
        c = stack(parse_line.(split(scanner, "\n", keepempty=false)[2:end]))
        #pad with 1's to make homogenous
        c = hcat(c, ones(Int, size(c)[1]))
        push!(coords, c)
    end
    
    return coords
    
end

#==#
encode_coord(coord::Matrix{Int64}) =  [
    Set(d[d .≠ 0]) for d in eachrow(pairwise_l1(coord))
]
encode_coord(coord::Set) = encode_coord(set2mat(coord))
alignments(e1,e2) = [
    ((i,j), length(e1[i] ∩ e2[j])) for (i,j) in all_pairs(e1, e2)
]
score(e1, e2) = maximum([v for (k,v) in alignments(e1,e2)])
matches(e1, e2) = [k for (k,v) in alignments(e1, e2) if v >= 11]

#=transform r2 to be in the reference frame of r1/
The combination of translations and rotations means r2 and r1
are related by a linear transformation. This function
solves for that linear transform

r1 * T = r2
=#
transform(r1, r2) = \(r1, r2)

function align(world, pts)
    Mw, Mp = set2mat(world), set2mat(pts)
    zw, zs = encode_coord(Mw), encode_coord(Mp)
    w_inds, pt_inds = unzip(matches(zw, zs))

    T = transform(Mp[pt_inds, :], Mw[w_inds, :])
    new_pts = round.(Int, Mp * T)
    
    scanner_pos = round.(Int, T' * [0,0,0,1])
    
    world = mat2set(vcat(Mw, new_pts))
    zw = encode_coord(world)
    
    return world, zw, scanner_pos
end

function build_world(coords)
    sets = mat2set.(coords)
    encs = encode_coord.(coords)
    
    world, zw = popat!(sets, 1), popat!(encs, 1)
    
    scanners = [[0,0,0,0]]
    
    while length(sets) > 0
        scores = (x->score(zw, x)).(encs)
        m, i = findmax(scores)
        pts, zs = popat!(sets, i), popat!(encs, i)
        world, zw, scanner = align(world, pts)
        push!(scanners, scanner)
    end
    return set2mat(world), stack(scanners)
end

coords = parse_input("input.txt");
world, scanners = build_world(coords)

world, scanners = build_world(coords);

println("Number of beacons: $(size(world)[1])")
println("Maximum manhattan dist: $(maximum(pairwise_l1(scanners)))")