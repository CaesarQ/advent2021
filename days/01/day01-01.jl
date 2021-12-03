using DelimitedFiles

depths = readdlm("input.txt", '\t', Int, '\n');
deltas = depths[2:end] - depths[1:end-1];

println("Number of times a depth measurement increases: $(sum(deltas .> 0))")