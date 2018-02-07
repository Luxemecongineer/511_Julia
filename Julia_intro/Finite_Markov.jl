using QuantEcon

ψ = [0.1,0.9] # Probabilities over sample space {1,2}
d = DiscreteRV(ψ);
# It ganna save two vectors, one of them is pdf, another is cdf.
rand(d,5)


#--- Test how to generate discrete dist
P = [0.2 0.5 0.3;
    0.1 0 0.9;
    0.3 0.2 0.5]
n = size(P)[1]
vec(P[2,:])
dists = [DiscreteRV(vec(P[i,:])) for i in 1:n]
dists[2]

#--- Then one could write a code as a funciton that takes three arguments
# 1. stochastic matrix P; 2. An initial state init; 3. sample_size that represents the length of time series
function mc_sample_path(P; init=1, sample_size=1000)
    X = Array{Int64}(sample_size)  #allocate memory
    X[1] = init
    #=== convert each row of P into a distribution ===#
    n = size(P)[1]  #obtains the # of rows, that specify tansition Probabilities
    P_dist = [DiscreteRV(vec(P[i,:])) for i in 1:n]

    #=== generate the sample path ===#
    for t in 1:(sample_size-1)
        X[t+1] = rand(P_dist[X[t]])
    end
    return X
end

# Let's test this functoin
P = [0.4 0.6; 0.2 0.8]
X = mc_sample_path(P, sample_size=100000)
println(mean(X .==1))

#--- One could directly use QuantEcon's Routines
P = [0.4 0.6; 0.2 0.8]
mc = MarkovChain(P)
X = simulate(mc, 100000);
println(mean(X.==1))

mc2 = MarkovChain(P, ["unemployed", "employed"])
tmp_1 = simulate(mc2, 10, init=1)
println(tmp_1)
tmp_2 = simulate(mc2, 10, init=2)
println(tmp_2)

#--- Stationary distribution
# definition of Stationary or invariant
P = [.4 .6; .2 .8]
ψ = [.25, .75]
typeof(ψ)
ψ'*P

# In QuantEcon
mc = MarkovChain(P);
stationary_distributions(mc)
