function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end

    splits = filter(x -> ~isempty(x), split(raw_input, r"\n| \| "))

    signals = splits[1:2:end]
    outputs = splits[2:2:end]

    return signals, outputs

end

signals, outputs = parse_input("input.txt")

count_1478(x) = sum(map(x -> x in [2,3,4,7], map(length, split(x, " "))))


println("Numer of times (1,4,7,8) appears: $(sum(count_1478.(outputs)))")