using SparseArrays

max_minus_min(x) = maximum(x) - minimum(x)

function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end
    
    return split(raw_input, "\n\n")
    
end

function get_components(pairs::AbstractString)
    components = split(pairs, r" -> |\n", keepempty=false)
    components = reshape(components, (2, length(components) ÷ 2))
    
    p, t = components[1, :], components[2, :]
    t = hcat([["$(_p[1])$(_t)", "$(_t)$(_p[2])"] for (_p, _t) in zip(p,t)]...)
    t1, t2 = t[1,:], t[2,:]
    
    return p, t1, t2
    
end

function construct_system(template::AbstractString, pairs::AbstractString)
    parent, child1, child2  = get_components(pairs)
    monomers = sort(unique(vcat(parent,child1,child2)))
    elements = sort(unique(split(join(monomers), "")))

    nm = length(monomers)
    ne = length(elements)

    #dictionaries mapping the strings to integers
    mV = Dict(monomers.=>1:nm)
    eV = Dict(elements.=>1:ne)
    
    #encoding parents and children
    pe = [mV[i] for i in parent]
    ce1 = [mV[i] for i in child1]
    ce2 = [mV[i] for i in child2]

    #building the count matrix
    M = hcat([[eV["$(m[1])"], eV["$(m[2])"]] for m in monomers]...)
    I = vcat(1:nm, 1:nm)
    J = vcat(M[1,:], M[2,:])
    Cmat = sparse(J, I, ones(Int, 2 * nm), ne, nm)
    
    #building the transition mat
    I = vcat(ce1, ce2)
    J = vcat(pe, pe)
    Tmat = sparse(I, J, ones(Int, 2 * nm), nm, nm)
    
    #constructing the initial state
    x0 = zeros(Int, nm)
    for i in 1:length(template)-1
        x0[mV[template[i:i+1]]] += 1
    end
    
    #constructing the offsets
    #this accounts for the fact that the ends of the template are
    #unpaired, and so the count matrix does not consider them
    offset = zeros(Int, ne)
    offset[eV["$(template[1])"]] = 1
    offset[eV["$(template[end])"]] = 1
    
    return Cmat, Tmat, x0, offset
end

template, pairs = parse_input("input.txt")
Cmat, Tmat, x0, offset = construct_system(template, pairs)
count_elements(xt) = (Cmat * xt + offset) .÷ 2

net_counts = count_elements((Tmat^10) * x0)
println("Count difference after 10: $(max_minus_min(net_counts))")

net_counts = count_elements((Tmat^40) * x0)
println("Count difference after 40: $(max_minus_min(net_counts))")