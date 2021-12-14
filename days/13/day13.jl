using SparseArrays

function parse_input(input_src::AbstractString)
    raw_input = open(input_src) do file
        read(file, String)
    end
    
    inds, folds = split(raw_input, "\n\n")
    inds = map(x -> parse(Int, x), split(inds, r"\n|\,"))
    
    inds = copy(transpose(reshape(inds, (2, length(inds) ÷ 2))))
    #start indexing at 1
    inds .+= 1
    
    folds = [m.match for m in eachmatch(r"[xy]=[0-9]+", folds)]
    
    return inds, folds

end

function build_sparse(inds)
    shape = tuple(maximum(inds, dims=1)[1, :]...)
    #the indices are reversed
    I = inds[:, 2]; J = inds[:,1];
    V = ones(Int, length(I))
    return sparse(I, J, V, shape[2], shape[1])
end

function perform_one_fold(arr, fold)
    m, n = size(arr)
    ax, ind = split(fold, "=")
    ind = parse(Int, ind) + 1
    I, J, _ = findnz(arr)
    
    
    if ax == "y"
        I1, I2 = I[I .< ind], I[I .> ind]
        J1, J2 = J[I .< ind], J[I .> ind]
        
        if ind < m - ind
            new_m, new_n = m - ind, n
            I1 = ind .- I1 .- 1
            I2 = I2 .- ind .- 1
        else
            new_m, new_n = ind - 1, n
            I2 = 2 * ind .- I2
        end
    else
        I1, I2 = I[J .< ind], I[J .> ind]
        J1, J2 = J[J .< ind], J[J .> ind]
        
        if ind < n - ind
            new_m, new_n = m, n - ind
            J1 = ind .- J1 .- 1
            J2 = J2 .- ind .- 1
        else
            new_m, new_n = m, ind - 1
            J2 = 2 * ind .- J2
        end
    end
    
    V1, V2 = ones(Int, length(I1)), ones(Int, length(I2))
    arr1 = sparse(I1, J1, V1, new_m, new_n)
    arr2 = sparse(I2, J2, V2, new_m, new_n)
    
    ret = arr1 + arr2
    ret[ret .≥ 1] .= 1
    return ret
    
end

function perform_all_folds(
        arr::SparseMatrixCSC{Int64, Int64}, 
        folds
    )

    folded = copy(arr)

    for (i,f) in enumerate(folds)
        folded = perform_one_fold(folded, f)

        if i == 1
           println("Number of dots after first fold: $(sum(folded))")
        end
    end

    return folded


end

inds, folds = parse_input("input.txt")
arr = build_sparse(inds)

folded = perform_all_folds(arr, folds)


println("Secret code:")
display(folded)
println()

