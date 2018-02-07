using LaTeXStrings
using QuantEcon
using Plots
pyplot()

α = β = 0.1
N = 10000
p = β / (α + β)

P = [1 - α       α   # Careful: P and p are distinct
         β   1 - β]

mc = MarkovChain(P)



labels = []
y_vals = []

for x0 = 1:2
    # == Generate time series for worker that starts at x0 == #
    X = simulate_indices(mc, N; init=x0)

    # == Compute fraction of time spent unemployed, for each n == #
    X_bar = cumsum(X.==1) ./ (collect(1:N))

    l = LaTeXString("\$X_0 = $x0\$")
    push!(labels, l)
    push!(y_vals, X_bar - p)
end

plot(y_vals, color=[:blue :green], fillrange=0, fillalpha=0.1,
     ylims=(-0.25, 0.25), label=reshape(labels,1,length(labels)))
gui()
