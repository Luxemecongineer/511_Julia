# Examples in this file comes from Quant-Econ
#---
using Plots
pyplot()
ts_length = 100
epsilon_values = randn(ts_length)

typeof(epsilon_values)
println(epsilon_values)
plot(epsilon_values, fmt= :png)
gui()
#--- How to use function to generate corresponding array
using Plots
pyplot()
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
gui()
#--- This cell using Distribution function to draw data
using Distributions
using Plots
pyplot()
function plot_histogram(distribution, n)
    epsilon_values = rand(distribution, n)  # n draws from distribution
    histogram(epsilon_values)
end

lp = Laplace()
plot_histogram(lp, 500)
gui()

#---  Following is my answer of exercises in https://lectures.quantecon.org/jl/julia_by_example.html
# Exercise 1
cache_n = 6
z = factorial(cache_n)
println(z)

function factorial2(n)
    i = 1
    k = 1
    for i in 1:n
        k = k*i
    end
    return k
end
w = factorial2(cache_n)
println(w)

#--- Exercise 2
function binomial_rv(n, p)
    count = 0
    U = rand(n)
    for i in 1:n

        if U[i] < p
            count = count + 1
        end
    end
    return count
end
test_rv1 = binomial_rv(50, 0.3)
println(test_rv1)
for j in 1:25
    b = binomial_rv(50, 0.3)
    print("$b, ")
end

println("Second method")

function binomial_rv2(n, p)
    A = Array{Int64}(n)
    for i in 1:n
        cache_v = rand(1)[1]
        if cache_v < p
            A[i]=1
        else
            A[i]=0
        end
    end
    count = sum(A)
    return count
end

for j in 1:25
    b = binomial_rv2(50, 0.3)
    print("$b, ")
end

#--- Exercise 3 Approximation of π
# For Monte Carlo, how many draws?
function pi_app()
    n = 1000000
    count = 0
    # Outer loop iterate all draws, innerloop compare the distance to diameter
    for i in 1:n
        cache_axis = rand(2)
        if sqrt((cache_axis[1]-0.5)^2+(cache_axis[2]-0.5)^2) < 0.5
            count += 1
        end
    end
    app_pi = (count/n)/((0.5)^2)
    return app_pi
end

z = pi_app()
println("Oneshot: π is appproximated as $z")


n = 1000
temp_app = 0
for j in 1:n
    temp_app += pi_app()
end
approxi_pi = temp_app/n
println("π is appproximated as $approxi_pi")

#--- Exercise 4
function oneshot_game()
    draws = 10
    sec_rule = 3
    count = 0
    payoff = 0

    U = rand(draws)
    # push!(U, 0.0)
    # push!(U, 0.0)
    U2 = Array{Int64}(draws)
    for i in 1:length(U)
        if U[i] <= 0.5
            count +=1
        else
            count = 0
        end
        if count ==3
            payoff =1
        end
    end
    return payoff
end
print(oneshot_game())
print("\n")

# Then compute the probability of winning this game
n = 10000
count = 0
for j in 1:n
    count += oneshot_game()
end
ratio = count/n
println("The probability of winning this game is $ratio")


#--- Plot three time series together
using Plots
pyplot()

alphas = [0.0, 0.8, 0.98]
T = 200

series = []
labels = []

for alpha in alphas
    x = zeros(T + 1)
    x[1] = 0
    for t in 1:T
        x[t+1] = alpha * x[t] + randn()
    end
    push!(series, x)
    push!(labels, "alpha = $alpha")
end
pyplot()
plot(series, label=reshape(labels, 1, length(labels)))
gui()
