operators = [+, *, min, max, x -> x, >, <, ==]
apply_op(op, values) = reduce(operators[op + 1], values)

hm = Dict(
    '0' => "0000",
    '1' => "0001",
    '2' => "0010",
    '3' => "0011",
    '4' => "0100",
    '5' => "0101",
    '6' => "0110",
    '7' => "0111",
    '8' => "1000",
    '9' => "1001",
    'A' => "1010",
    'B' => "1011",
    'C' => "1100",
    'D' => "1101",
    'E' => "1110",
    'F' => "1111",
)

binarize(x::Char) = hm[x]
binarize(x::String) = x |> collect .|> binarize |> join
parse_int(bits::String) = parse(Int, bits, base=2)

function parse_literal(bstream)
    bin_num = ""
    while true
        is_last_block = !Bool(parse_int(bstream(1)))
        bin_num *= bstream(4)
        is_last_block && break
    end
    return parse_int(bin_num)
end

function parse_bits(hex_str)
    bits = binarize(hex_str)
    version_sum = 0
    
    function parse_stream(head)
        bstream(cnt) = bits[head:((head+=cnt)-1)]
        istream(cnt) = cnt |> bstream |> parse_int
        
        function parse_operator(op_id)
            length_type_id = Bool(istream(1))
            n = istream(length_type_id ? 11 : 15)
            values = []
            
            if length_type_id == 0
                target = head + n
                while head < target
                    head, val = parse_stream(head)
                    push!(values, val)
                end
            else
                for _ in 1:n
                    head, val = parse_stream(head)
                    push!(values, val)
                end
            end
            
            return apply_op(op_id, values) |> Int
        end
        
        version_sum += istream(3)
        op_id = istream(3)
        
        value = op_id == 4 ? parse_literal(bstream) : parse_operator(op_id)
        
        return head, value
        
    end
    
    _, sol = parse_stream(1)
    
    return version_sum, sol
end

hex_str = readlines("input.txt")[1]
version_sum, sol = parse_bits(hex_str)
println("Version sum: $version_sum, evaluation: $sol")