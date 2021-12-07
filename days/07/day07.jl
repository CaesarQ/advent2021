using DelimitedFiles

#Load data
input = readdlm("input.txt", ',', Int, '\n')[1, :];
#input = readdlm("sample.txt", ',', Int, '\n')[1, :];
N = size(input)[1]

fuel1(pos, x) = sum(abs.(pos .- x))

#We derive a solution analytically
#We consider two elements, x1 and x2, with x1<x2.  
#The objective is |x1 - x| + |x2 - x|.
#It is clear that the solution x* must lie within the interval [x1,x2].  
#This is easy to prove by contradiction: suppose an optima x* exists for which
#x* < x1.  Let x1 - x* = d
#Then there exists a point x' = x1 + d for which |x1 - x| is unchanged, but 
#|x2 - x| has been reduced.  This is a contradiction.

#Now consider a larger list of elements x1 < x2 < .... < xN
#We consider the maximum and minimum elements of this list, x1 and xN.
#From the above, we know the minima must lie between x1 and xN.  We may 
#recursively remove all such max/min pairs.  If the list has an odd number of
#elements, the only point remaining will be the median value, which is our 
#minima.  On the other hand, for an even list, it will lie at the midpoint
#between the last two remaining elements.

#This can be seen another way.  The loss function is \sum |x - xi|
#While we cannot take a derivative, the sub gradient will be given by a sum of
#sign functions sign(x - xi).  We look for the transition point when this sum 
#goes from negative to positive.  But this transition occurs precisely at the
#median.

sorted = sort(input)

if N %2 == 1
    median = sorted[Int(N/2)]
else
    median = sorted[Int(floor(N/2))]
end

println("Optimal fuel cost (part 1): $(fuel1(input, median))")

function fuel2(pos, x)
    n = abs.(pos .- x)
    return convert(Int, floor(sum(n .* (n .+ 1) / 2)))

end

#The sum of the integers from 1:N is given by N * (N + 1) / 2
#This is just the sum of an arithmetic series.
#We can expand this sum as 1/2 * N + 1/2 * N^2 = L1 + L2
#Our loss function is thus the sum of two loss functions.
#The first loss L1 is the same as the loss we previously optimized.
#The second is similar, but corresponds to a sum of squares, rather than
#absolute values.  The gradient is given by:
#dL2/dx = \sum_i 2*(x - xi) = 2*Nx - 2*\sum_i xi 
#Thus the total sub gradient is:
#G = Nx - \sum_i xi + 1/2 * sum_i sign(x - xi)

#As an approximate solution, let us find a relaxation of sum_i sign(x - xi)
#This is equal to -N when x < xmin, and N when x > xmax
#Let us adopt the convention that sign(0) = 0
#Then at x=xmin, sum_i sign(xmin - xi) = -N + 2
#At x=xmax, sum_i sign(xmax-xi) = N
#Therefore, we can fit a line as follows:
#slope = [N - (-N + 2)] / (xmax-xmin) = (2N - 2) / (xmax - xmin) = m
#(y - N) = m(x - xmax)
#y = m*x + N - m*xmax

#We thus want to find the intersection of the following lines:
#y1 = 0.5*m*x + 0.5*N - 0.5*m*xmax
#y2 = N*xmean - N*x

#This occurs at:
#x = (N * xmean - N/2 + m*xmax/2) / (m/2 + N)


mean = sum(input) / N
xmax, xmin = max(input...), min(input...)
slope = (2 * N - 2) / (xmax - xmin)

optima = convert(Int, floor((N * mean - N/2 + slope * xmax/2) / (slope/2 + N)))

println("Optimal fuel cost (part 2): $(fuel2(input, optima))")
