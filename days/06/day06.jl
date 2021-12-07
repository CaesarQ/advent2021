using DelimitedFiles

function bincount(arr::Matrix{Int}, minlength::Int)
    ret = zeros(Int64, minlength)
    for k in arr
        ret[k] += 1
    end
    return ret 
end


# Load data
input = readdlm("input.txt", ',', Int, '\n');
# Initial population
p0 = bincount(input .+ 1, 9)
T = readdlm("transitions.txt", ',', Int, '\n')

println("Population after 80 days: $(sum((T^80) * p0))")
println("Population after 256 days: $(sum((T^256) * p0))")
