using LinearAlgebra

isbig(s) = all(isuppercase, s)
get_inds(shape, row, col) = LinearIndices(shape)[CartesianIndex.(row, col)]

function remove_upper(arr::Matrix{Int64}, inds_to_delete::Vector{Int64})
    ret = zeros(Int, size(arr)) + arr
    
    for i ∈ reverse(sort(inds_to_delete))
        V = ret[i,:] * transpose(ret[i,:])
        V -= Diagonal(V)
        ret = (ret + V)[1:end .!= i, 1:end .!= i]


    end

    return ret
end

function parse_input(input_src)
    V0, V1 = [], []
    for l in readlines(input_src)
        a, b = split(l, "-")
        push!(V0, a); push!(V1, b)
    end
    
    nodes = unique(vcat(V0, V1))
    N = length(nodes)
    
    nodes = sort(filter(x -> !(x ∈ ["start", "end"] ), nodes))
    upper_nodes = filter(isbig, nodes)
    
    node_dict = Dict(nodes .=> 2:length(nodes)+1)
    node_dict["start"] = 1; node_dict["end"] = N
    
    V0 = [node_dict[i] for i in V0]
    V1 = [node_dict[i] for i in V1]
    upper_nodes = [node_dict[i] for i in upper_nodes]
    
    adj = zeros(Int, (N, N))
    
    adj[get_inds((N,N), V0, V1)] .+= 1
    adj += transpose(adj)
    
    adj = remove_upper(adj, upper_nodes)
    
    return adj
end


score(adj, path) = prod(adj[get_inds(size(adj), path[1:end-1], path[2:end])])

function enumerate_paths(adj, src, dest)
    all_paths = []
    
    function dfs(start, visited, depth)
        push!(visited, start)
        
        if start == dest
            push!(all_paths, copy(visited))
            return
        end
        
        candids = findall(adj[start, :] .≠ 0)
        
        for c in candids
            if c ∈ visited
                continue
            else
                dfs(c, visited, depth + 1)
                pop!(visited)
            end
        end
        
        return
    end

    dfs(src, Int.([]), 1)
    return all_paths
end

adj = parse_input("input.txt")
paths = enumerate_paths(adj, 1, size(adj)[1])
num_paths = sum(score(adj, p) for p in paths)

println("Number of paths: $(num_paths)")