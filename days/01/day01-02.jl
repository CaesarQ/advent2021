using DelimitedFiles

function count_pos_deltas(signal::Array{Int64})
    deltas = signal[2:end] - signal[1:end-1];
    return (sum(deltas .> 0))
end

depths = readdlm("input.txt", '\t', Int, '\n');

#Solution 1: Hard coded
sol1 = depths[1:end-2] + depths[2:end - 1] + depths[3:end]
println("Number of times a depth measurement increases: $(count_pos_deltas(sol1))")

#Solution 2: Sliding window views
window = 3
n = length(depths)
windows = view.(Ref(depths), (:).(1:n-(window-1),window:n))
sol2 = map(sum, windows)

println("Number of times a depth measurement increases: $(count_pos_deltas(sol2))")

#Solution 3: avoiding redundant calculation
#Each element of the window sum will have the form:
#(a[i + 1] + a[i + 2] + a[i + 3]) - (a[i] + a[i + 1] + a[i + 2]) = a[i + 3] - a[i + 1]

window_deltas = depths[1 + window:end] - depths[1:end - window];

println("Number of times a depth measurement increases: $(sum(window_deltas .> 0))")