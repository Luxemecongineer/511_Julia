# Examples in this file comes from Quant-Econ
#---
using Plots
ts_length = 100
epsilon_values = randn(ts_length)

typeof(epsilon_values)
println(epsilon_values)
plot(epsilon_values, fmt= :png)
gui()
#--- How to use function to generate corresponding array
using Plots
function generate_data(n)
    epsilon_values = Array{Float64}(n)
    for i = 1:n
        epsilon_values[i] = randn()
    end
    return epsilon_values
end

ts_length =150
data = generate_data(ts_length)
plot(data, fmt=:png)

#--- This cell using Distribution function to draw data
using Distributions

function plot_histogram(distribution, n)
    epsilon_values = rand(distribution, n)  # n draws from distribution
    histogram(epsilon_values)
end

lp = Laplace()
plot_histogram(lp, 500)

#---  Following is my answer of exercises in https://lectures.quantecon.org/jl/julia_by_example.html
# Exercise 1
cache_n = 6
z = factorial(cache_n)
println(z)

function factorial2(n)
    i = 1
    out = 1
    while i <= n
        out*=i
    end
    return out
end
w = factorial2(cache_n)
println(w)
