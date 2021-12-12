using Base.Cartesian

stack(x) = copy(transpose(hcat(x...)))

#modified fromhttps://github.com/aamini/FastConv.jl
@generated function fastconv(E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote

        retsize = [size(E)...] + [size(k)...] .- 1
        retsize = tuple(retsize...)
        ret = zeros(T, retsize)

        @inbounds begin
            @nloops $N x E begin
                @nloops $N i k begin
                    (@nref $N ret d->(x_d + i_d - 1)) += (@nref $N E x) * (@nref $N k i)
                end
            end
        end
        
        return ret
    end
end

function conv(E::Array{T,N}, k::Array{T,N}) where {T,N}
    ret = fastconv(E,k)
    start = [size(k)...] .- 1
    tar = start + [size(E)...] .- 1
    return ret[[s:t for (s,t) in zip(start,tar)]...]
end

function parse_input(input_src::String)
    return stack([
        map(x -> parse(Int, x), split(x, "")) for x in readlines(input_src)
    ])
end


kern = ones((3,3))
kern[2,2] = 0.

propagate(x) = conv(float(x), kern) .* (1 .- x)

function step(arr::Matrix{Int64})
    flashes = zeros(Bool, size(data))
    #step 1: add 1
    ret = arr .+ 1
    
    #step 2: flashes
    while true
        _flash = ret .> 9
        flashes = flashes .|| _flash
        neighbours = propagate(_flash)
        new_ret = ret + neighbours
        new_ret[flashes] .= 0
        
        if new_ret ≠ ret
            ret = new_ret
        else
            break
        end
    end
    
    return Int.(ret), flashes
end

function count_flashes(arr::Matrix{Int64}, num_steps::Int)
    counts = 0
    new_arr = copy(arr)

    for i in 1:num_steps
        new_arr, flashes = step(new_arr)
        counts += sum(flashes)
    end
    
    return counts
end

function synchronize(arr::Matrix{Int64})
    num_steps = 10000

    new_arr = copy(arr)

    for i in 1:num_steps
        new_arr, flashes = step(new_arr)
        if sum(flashes) == length(data)
            return i
        end
    end

    println("COULD NOT FIND SYNCHRONIZATION")
end

data = parse_input("input.txt")

counts = count_flashes(data, 100)

println("Total flashes: $(counts)")

all_flashed = synchronize(data)

println("Synchronization step: $(all_flashed)")