function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end
    raw_lines = split(raw_input, "\n")[1:end-1]
    raw_coords = map(x -> split(x, r" -> |,"), raw_lines)

    data = copy(transpose(
        hcat(map(x -> map(y -> parse(Int, y), collect(x)), raw_coords)...)
    ))

    return data

end

data = parse_input("input.txt")

min_x = min(min(data[:, 1]...), min(data[:, 3]...))
max_x = max(max(data[:, 1]...), max(data[:, 3]...)) + 1

min_y = min(min(data[:, 2]...), min(data[:, 4]...))
max_y = max(max(data[:, 2]...), max(data[:, 4]...)) + 1

grid = zeros(Int, (max_x - min_x, max_y - min_y))

for row in eachrow(data)
    x1, y1, x2, y2 = row

    _x1 = x1 - min_x + 1
    _y1 = y1 - min_y + 1
    _x2 = x2 - min_x + 1
    _y2 = y2 - min_y + 1

    if x1 == x2
        start, dest = (y2 > y1) ? (_y1,_y2) : (_y2, _y1)
        grid[_x1, start:dest] .+= 1
    elseif y1 == y2
        start, dest = (x2 > x1) ? (_x1,_x2) : (_x2, _x1)
        grid[start:dest, _y1] .+= 1

    end
end

number_overlaps = sum(grid .> 1)

println("Number of overlaps: $(number_overlaps)")