# Sen Lu, example comes from https://lectures.quantecon.org/jl/discrete_dp.html#ddp-algorithms

using LaTeXStrings
# Model setup and primitive see lecture.

struct SimpleSA{TI<:Integer, T<:Real,
    TR<: AbstractArray{T}, TQ<:AbstractArray{T}}
    B::TI
    M::TI
    α::T
    β::T
    R::TR
    Q::TQ
end

function SimpleSA{T<:Real}(;B::Integer=10,M::Integer=5,α::T=0.5,β::T=0.9)
    # Here re-specify type T to generate payoff matrix and transition matrix in function.

    u(c) = c^α  # define the periodic payoff function
    n = B + M + 1   #define the state space/ size of the space
    m = M + 1   #define the action space/ size of the space

    R = Matrix{T}(n,m)  #specify the type and the size.
    Q = zeros(Float64,n,m,n)    #set it to zeros, then one just need to update non-zero elements.

    #create two primitive matrices
    for a in 0:M
        Q[:, a + 1,(a:(a+B))+1] = 1/(B+1)
        for s in 0:(B+M)
            R[s+1,a+1] = a<=s ? u(s-a):-Inf
        end
    end
    return SimpleSA(B,M,α,β,R,Q)
end




# structure and corresponding function specify a container for models' primitive
# call the corresponding function, could create an instance of SimpleSA, that stores primitives we want.
g=SimpleSA()

g # stores all primitives

using QuantEcon
ddp = DiscreteDP(g.R, g.Q, g.β)
results = solve(ddp,PFI)

# value function
results.v

# policy function
results.sigma-1 #subtract 1, bc we start our discrete state from 1.

# Controlled transition probability matrix
results.mc
dist = stationary_distributions(results.mc)[1]  # the results return a vector, though only one dist.

#--- PLot distribution
using Plots
pyplot()
plot(dist, t=[:bar], label="Stationary Dist 1")
# savefig("MyPlot1.pdf")
gui()

#--- One could set previous results as benchmark, then compare it with different primitives
g_2 = SimpleSA(β=0.99)  #One could notice that this structure could easy create new container.
ddp_2 = DiscreteDP(g_2.R, g_2.Q, g_2.β)
results_2 = solve(ddp_2,PFI)

# extract new results.
dist_2 = stationary_distributions(results_2.mc)[1]
pyplot()
plot(dist_2, t=[:bar], label="Stationary Dist 2")
# savefig("MyPlot2.pdf")
gui()



# The best way to compare is ploting them as subplots respectively.
dist_0 = Vector{AbstractArray}(2)
dist_0[1] = dist
dist_0[2] = dist_2
pyplot()
plot(dist_0,t=[:bar], layout=2)
gui()
#subplots
