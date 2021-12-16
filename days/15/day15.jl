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
deltas = [(0, 1), (1, 0), (-1, 0), (0, -1)]

function neighbours(x, grid)
    shape = size(grid)
    return filter(x -> within_grid(x, shape), [plus(x, δ) for δ in deltas])
end

function a_star_search(grid, start, target)
    cost_so_far = Dict()
    cost_so_far[start] = 0
    
    dims = size(grid)
    
    frontier = Pqueue()
    push_pq!(frontier, start, 0)    
    
    while length(frontier) ≠ 0
        current, val = pop_pq!(frontier)
        
        if current == target
            break
        end
        
        for next in neighbours(current, grid)
            new_cost = cost_so_far[current] + grid[next...]
            
            if next ∉ keys(cost_so_far) || new_cost < cost_so_far[next]
                cost_so_far[next] = new_cost
                priority = new_cost + heuristic(target, next)
                push_pq!(frontier, next, priority)    
            end
            
        end
    end
    
    return cost_so_far[target]
end

grid = parse_input("input.txt")
println("Lowest risk: $(a_star_search(grid, (1,1), size(grid)))")