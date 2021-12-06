inds_from_rowcol(shape, row, col) = LinearIndices(shape)[CartesianIndex.(row, col)]


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

function compute_num_overlaps(data::Matrix{Int64}, include_diag::Bool)
    min_x = min(min(data[:, 1]...), min(data[:, 3]...))
    max_x = max(max(data[:, 1]...), max(data[:, 3]...)) + 1

    min_y = min(min(data[:, 2]...), min(data[:, 4]...))
    max_y = max(max(data[:, 2]...), max(data[:, 4]...)) + 1

    nx, ny = max_x - min_x, max_y - min_y
    grid = zeros(Int, (nx, ny))

    for row in eachrow(data)
        x1, y1, x2, y2 = row

        _x1 = x1 - min_x + 1
        _y1 = y1 - min_y + 1
        _x2 = x2 - min_x + 1
        _y2 = y2 - min_y + 1

        if x1 == x2
            grid[_x1, _y1:sign(_y2 - _y1):_y2] .+= 1
        elseif y1 == y2
            grid[_x1:sign(_x2 - _x1):_x2, _y1] .+= 1
        elseif include_diag
            slope = (y2 - y1) / (x2 - x1)
            if abs(slope) == 1
                rows = _x1:sign(_x2 - _x1):_x2
                cols = _y1:sign(_y2 - y1):_y2
                grid[inds_from_rowcol((nx, ny), rows, cols)] .+= 1
            end
        end
    end

    return sum(grid .> 1)

end


println("Number of overlaps (ignoring diagonals): $(compute_num_overlaps(data, false))")
println("Number of overlaps (with diagonals): $(compute_num_overlaps(data, true))")