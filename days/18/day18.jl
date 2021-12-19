mutable struct Tree
    #=
    The paths (left/right) to reach the leaves.
    0 indicates left, 1 indicates right
    =#
    paths::Vector{Vector{Int64}}
    #=
    The values stored at the leaves.  These correspond to regular numbers
    =#
    vals::Vector{Int64} #the priorities for sorting
end
Tree() = Tree([], Int64[])  # empty tree
Tree(t::Tree) = Tree([copy(l) for l in t.paths], copy(t.vals))

function shift(t::Tree, dir::Int)
    #Takes a given tree, and shifts it down left/right
    st = Tree(t)
    for l in st.paths
        pushfirst!(l, dir)
    end
    return st
end

shift_left(t::Tree) = shift(t, 0)
shift_right(t::Tree) = shift(t, 1)

function str2tree(str::AbstractString)
    _path = []
    depth = 0
    paths = []
    vals = []
    for c in str
        if c == '['
            push!(_path, 0)
        elseif c == ']'
            _path = _path[1:end-1]
        elseif c == ','
            push!(_path, 1)
        elseif isnumeric(c)
            #=
            Assume all the numbers we are parsing are already reduced. As such,
            all the regular numbers are less than 10, so we only need to check
            for single digits.
            =#
            push!(vals, parse(Int, c))
            push!(paths, copy(_path))
            _path = _path[1:end-1]
        end
    end 
    return Tree(paths, vals)
end

function explode!(t::Tree, i::Int)
    if i > 1
        t.vals[i-1] += t.vals[i]
    end
    if i + 1 < length(t.vals)
        t.vals[i + 2] += t.vals[i+1]
    end

    insert!(t.vals, i, 0)
    insert!(t.paths, i, t.paths[i][1:end-1])
    
    deleteat!(t.vals, i + 1)
    deleteat!(t.vals, i + 1)
    
    deleteat!(t.paths, i + 1)
    deleteat!(t.paths, i + 1)
    
end

function split!(t::Tree, i::Int)
    lchild = copy(t.paths[i])
    push!(lchild, 0)
    rchild = copy(lchild)
    pop!(rchild)
    push!(rchild, 1)
    
    v = t.vals[i]
    vl, vr = floor(Int, v/2), ceil(Int, v/2)
    
    deleteat!(t.vals, i)
    deleteat!(t.paths, i)
    
    insert!(t.vals, i, vl)
    insert!(t.paths, i, lchild)
    
    insert!(t.vals, i + 1, vr)
    insert!(t.paths, i + 1, rchild)
end

function add(tl::Tree, tr::Tree)
    t = Tree(shift_left(tl))
    trr = shift_right(tr)
    
    push!(t.paths, trr.paths...)
    push!(t.vals, trr.vals...)

    return t
end

function reduce_num!(t::Tree)
    while true
        i = findfirst(x->length(x) >= 5, t.paths)
        if !isnothing(i)
            explode!(t, i)
            continue
        end
        i = findfirst(t.vals .>= 10)
        if !isnothing(i)
            split!(t, i)
            continue
        end
        break
    end
    return t
end

add_and_reduce(t1::Tree, t2::Tree) = reduce_num!(add(t1,t2))

function magnitude(t::Tree)
    #=
    Each leaf acquires a power of 3 every time it is the left child of a node,
    and a power of 2 every time it is the right child.
    =#
    R = sum.(t.paths)
    L = length.(t.paths) - R
    w = 3 .^ L .* 2 .^ R
    return sum(w .* t.vals)
end

function max_magnitude(nums)
    N = length(nums)
    ret = -Inf
    for i in 1:N
        for j in 1:N
            if i == j
                continue
            else
                num_sum = add_and_reduce(nums[i], nums[j])
                p = magnitude(num_sum)
                if p > ret
                    ret = p
                end
            end
        end
    end
    return ret
end

nums = str2tree.(readlines("input.txt"))
snailfish_num_sum = reduce(add_and_reduce, nums)
println("Magnitude of the snailfish sum: $(magnitude(snailfish_num_sum))")
println("Maximum magnitude of pairs: $(max_magnitude(nums))")

