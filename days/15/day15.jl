import Base.length 

stack(x) = copy(transpose(hcat(x...)))

function parse_input(input_src)
    return stack([
        map(x -> parse(Int, x), split(x, "")) for x in readlines(input_src)
    ])
end

#=
Implementation of a Priority Queue

Based on answer here:
https://discourse.julialang.org/t/fastest-data-structure-for-a-priority-queue/68472
=#

mutable struct Pqueue
    k::Vector{Tuple{Int64, Int64}} #the info to store
    v::Vector{Int64} #the priorities for sorting
end
Pqueue() = Pqueue(Int64[], Int64[])  # constructor (empty queue)

function push_pq!(pq::Pqueue, ki, vi)
    left = searchsortedfirst(pq.v, vi)
    insert!(pq.k, left, ki)
    insert!(pq.v, left, vi)
end

function pop_pq!(pq::Pqueue)
    ki = popfirst!(pq.k)
    vi = popfirst!(pq.v)
    return (ki, vi) #returns the first index
end

function length(pq::Pqueue)
    return length(pq.k)
end

heuristic(start, target) = abs(target[2] - start[2]) + abs(target[1] - start[1])
within_grid(x, shape) = 1 <= x[1] <= shape[1] && 1 <= x[2] <= shape[2]
plus(t1::Tuple{Int64, Int64}, t2::Tuple{Int64, Int64}) = (t1[1] + t2[1], t1[2] + t2[2])

function get_expanded(x, grid, expand)
    #=
    While in principle we could just create a bigger matrix using the rules
    described, it's more memory efficient to just reindex the existing
    sub-matrix.
    =#
    shape = size(grid)
    new_x = ((x[1] - 1) % shape[1] + 1, (x[2] - 1) % shape[2] + 1)

    if expand > 1
        offset = (x[1] - 1) ÷ shape[1] + (x[2] - 1) ÷ shape[2]
    else
        offset = 0
    end

    risk = grid[new_x...] + offset

    return (risk - 1) % 9 + 1
end

deltas = [(0, 1), (1, 0), (-1, 0), (0, -1)]

#=
Implementation of A* search
Based on: https://www.redblobgames.com/pathfinding/a-star/introduction.html
=#

function a_star_search(grid, start, target, expand)
    cost_so_far = Dict()
    cost_so_far[start] = 0

    shape = size(grid)
    expanded_shape = (expand * shape[1], expand * shape[2])
    
    frontier = Pqueue()
    push_pq!(frontier, start, 0)    
    
    while length(frontier) ≠ 0
        current, _ = pop_pq!(frontier)
        
        if current == target
            break
        end
        
        for δ in deltas
            next = plus(current, δ)
            !within_grid(next, expanded_shape) && continue
            new_cost = cost_so_far[current] + get_expanded(next, grid, expand)
            
            if next ∉ keys(cost_so_far) || new_cost < cost_so_far[next]
                cost_so_far[next] = new_cost
                priority = new_cost + heuristic(target, next)
                push_pq!(frontier, next, priority)    
            end
            
        end
    end
    
    return cost_so_far[target]
end

subgrid = parse_input("input.txt")
target = size(subgrid)
println("Lowest risk (subgrid): $(a_star_search(subgrid, (1,1), target, 1))")

target = (5 * target[1], 5 * target[2])
println("Lowest risk (fullgrid): $(a_star_search(subgrid, (1,1), target, 5))")