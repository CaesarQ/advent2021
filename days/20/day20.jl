using ImageFiltering

binarize(c::Char) = c == '.' ? 0 : 1
binarize(s::AbstractString) = binarize.(collect(s))

stack(x) = copy(transpose(hcat(x...)))

function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end
    
    splits = split(raw_input, "\n", keepempty=false)
    
    alg, image = splits[1], splits[2:end]
    
    alg = binarize(alg)
    image = stack(binarize.(image))
    
    return alg, image
    
end

function pad(mat::Matrix{Int64}, padding::Int64, fill_value::Int64)
    m, n = size(mat)
    padded = ones(Int64, m + 2 * padding, n + 2 * padding) * fill_value

    padded[1+padding:padding+m, 1+padding:padding+n] .= mat

    return padded

end

power_kernel = reshape(reverse(2 .^ (0:8)), 3,3)'
power_kernel = centered(power_kernel)
power_conv(x) = imfilter(x, power_kernel)
enhance_image(image, alg) = alg[power_conv(image) .+ 1]

alg, image = parse_input("input.txt")

function iterated_enhance(image, alg, steps)
    #=
    There is some subtlety about the behaviour at infinity
    Infinity is initlaized to be all zeros.
    Thus, the background shifts to alg[b'000000000 + 1] (the +1 is because 
    julia starts its indexing at 1)
    To handle this, the convolution function using replifcation padding
    =#
    for _ in 1:steps
        image = enhance_image(image, alg)
    end
    return image
end

padded = pad(image, 50, 0);

image_2 = iterated_enhance(padded, alg, 2)
println("Number of lit pixels (2 steps): $(sum(image_2))")

image_50 = iterated_enhance(padded, alg, 50)
println("Number of lit pixels (50 steps): $(sum(image_50))")