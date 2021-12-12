#helper funcs

function cartesianprod(x,y)
    leny=length(y)
    lenx=length(x)
    m=leny*lenx
    ret = zeros(Int64, m,2)
    c=1
    for i = 1:lenx
        for j = 1:leny
            ret[c,1] = x[i]
            ret[c,2] = y[j]
            c+=1
        end
    end 
    return ret
end

function extend_set!(s::Set, arr::Matrix)
    for a in eachrow(arr)
        push!(s, tuple(a...))
    end
end

function load_box(input_src)
    raw_input = readline(input_src)
    pattern = r"-?\d+\.\.-?\d+"
    coords = map(eachmatch(pattern, raw_input)) do m
        [parse(Int, s) for s in split(m.match, "..")]
    end

    xmin, xmax = coords[1]
    ymin, ymax = coords[2]

    #what if x is a batch?
    

    return xmin, xmax, ymin, ymax
end

#=
Analytical solution:
Based on the dynamics above, we see that there is no coupling between motion
in x and y directions.  Therefore, we can treat them as separate dynamical systems.

Thus, consider a probe starting at y=0, and moving upwards at a positive
velocity vy0.  It reaches a maximum height yh when the velocity becomes 0.  To 
solve this, we note the velocity equation:

v(t+1) = v(t) - 1

Is solved by:

v(t) = v(0) - t

Since v(tmax) = 0, tmax = v(0)

yh = y(tmax) = y0 + \sum_t^{tmax} v(t)
             = y0 + \sum_t^{v(0)} (v(0) - t) #sum of arithmetic series
             = y0 + v(0) * (v(0) - 1) / 2 #y0 = 0
             = v(0) * (v(0) + 1) / 2

At the maximum height yh, this velocity becomes zero, and then begins
decreasing.  From here, the velocity decreases by 1 at every time step, thus:

v(tmax + t) = -t

The height over time may thus be described by:

y(tmax + t) = yh + \sum_i^t v(tmax + t) = yh - \sum_i^t t 
            = yh - t * (t + 1)/2

In particular, y(2 * tmax) = 0, v(2 * tmax) = -v(0) - 1

At this position, and with this velocity, if the velocity is greater than ymin
(the lower bound for the box), it will simply overshoot the box.  As such:

-v(0) - 1 = ymin; v(0) = -ymin - 1

yh = (-ymin) * (-ymin - 1) / 2

=#

xmin, xmax, ymin, ymax = load_box("input.txt")
yh = (-ymin) * (-ymin - 1) / 2
println("Max height: $yh")

#=
Other constraints:

To find a bound on vx(0), we may observe, as we did before, that vx(0) < xmax
Furthermore, note that if vx(0) is too low, it will decay to 0 before reaching
the target.  After t steps, we have:

vx(t) = vx(0) - t => t = vx(0) - vx(t)
x(t) = t * vx(0) + t * (t - 1) / 2

In order to reach the target, we must have xmin <= x(t) <= xmax, whereupon 
vx(t) = 0.  Stepping backwards in time, vx(t-1) = 1, vx(t-2) = 2....

Thus, xmin = \sum_t=1^{vx(0)} t = vx(0) * (vx(0) + 1) / 2

Using the quadratic formula, our bound on vx(0) is:

vx(0) > (sqrt(8*a+1) - 1) / 2

=#

asum(a::Int64) = a * (a + 1) ÷ 2
arcsum(a::Int64) = (sqrt(8*a+1) - 1) / 2
interval(a::Float64,b::Float64) = collect(Int(ceil(a)):Int(floor(b)))
vyrange(t::Int64) = interval((ymin + asum(t)) / t - 1, (ymax + asum(t)) / t - 1)
partial_sum(a::Int64,b::Int64) = asum(b) - asum(a)

function vxrange(t)
    Δ = asum(t)
    if Δ > xmax
        l = arcsum(xmin)
        u = arcsum(xmax)
    elseif Δ < xmin
        l = (xmin - Δ)/t + t
        u = (xmax - Δ)/t + t
    else
        l = arcsum(xmin)
        u = (xmax - Δ)/t + t
    end
    return interval(l, u)
end

function find_sat()
    #=
    The path which takes the longest is the path that shoots the highest into
    the air.  As established, this occurs for vy(0) = abs(ymin). The number of
    time steps for this path is 2 * abs(ymin), since it loops back upon itself.
    =#
    Tmax = 2 * abs(ymin)
    coords = Set()
    for t in 1:Tmax
        #These are the initial values of vx/vy which reach the target
        #in t steps
        cx, cy = vxrange(t), vyrange(t)
        #=
        We cannot simply take the product of the lengths of these arrays.
        This is because some configurations might be repeated (i.e the probe
        may spend multiple time steps inside the target).  Thus, we must 
        collect them all, and count the unique configurations.
        =#
        extend_set!(coords, cartesianprod(cx,cy))
    end
    return coords
end

coords = find_sat()
println("Total combinations: $(length(coords))")