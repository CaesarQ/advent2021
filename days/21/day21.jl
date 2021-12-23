deltas = [3,4,5,6,7,8,9]
PMD = Dict(deltas.=>[1,3,6,7,6,3,1])

modm(x,m) = (x - 1) % m + 1
mod10(x) = modm(x,10)

function parse_input(input_src::AbstractString)
    s = open(input_src) do file
        read(file, String)
    end
    
    return [parse(Int, x.match) for x in eachmatch(r"\d+", s)][[2,4]]
end

function deterministic_game(x10, x20)
    pos = [x10, x20] #board pos
    scores = [0, 0] #accumalated scores

    cnt = 0 #turn coutner
    die = 1 #counter for the die

    while(max(scores...) < 1000)
        player, cnt = cnt % 2, cnt + 1
        #you don't have to do %100 on the die, because you are already doing
        #%10 for the score increment
        pos[player + 1], die = pos[player + 1] + 3 * die + 3, die + 3
        scores[player + 1] += mod10(pos[player + 1])
    end
    return 3cnt * min(scores...)
end

function dstep(x,s,δ)
    xp = mod10(x + δ)
    sp = min(s + xp, 21)
    return xp, sp
end

function step(x1,s1,x2,s2,t,δ) 
    if t == 1
        return (dstep(x1,s1,δ)...,x2,s2,2)
    else 
        return (x1,s1,dstep(x2,s2,δ)...,1)
    end
end

function quantum_game(x10, x20)
    #we use the cache to avoid repeated computation
    cache = Dict()
    function simulate(x1, s1, x2, s2, t)
        #try/catch is faster than checking for membership
        try
            return cache[(x1, s1, x2, s2, t)]
        catch KeyError
            if s1 >= 21
                wins = [1, 0]
            elseif s2 >= 21
                wins = [0, 1]
            else
                wins = [0, 0]
                for δ ∈ deltas
                    wins += PMD[δ] * simulate(step(x1,s1,x2,s2,t,δ)...)
                end
            end
            cache[(x1, s1, x2, s2, t)] = wins
            return wins
        end
    end
    
    return simulate(x10, 0, x20, 0, 1)
end

x10, x20 = parse_input("input.txt")
println("Min score * number of die rolls = $(deterministic_game(x10, x20))")
println("Max score of quantum game: = $(max(quantum_game(x10, x20)...))")