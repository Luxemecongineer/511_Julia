#Sen Lu. Stochastic Optimal Growth Model. Example from QuantEcon
#=== Some points while coding:
(1) Stochastic comes from random TFP shock.
(2) The problem is about how to write it in a hidden Markovian Model
(3) try to think about state variables, and choice variables.
(4) The "question" itself is Markovian.
===#

using QuantEcon
using Optim

"""
Arguments of function:

    `w` : Vector
        The value of the input function on different grid points
    `grid` : Vector
         The set of grid points
`β` : AbstractFloat
         The discount factor
`u` : Function
      The utility function
`f` : Function
      The production function
`shocks` : Vector
           An array of draws from the shock, for Monte Carlo integration (to
           compute expectations).
`Tw` : Vector, optional (default=similar(w))
       Array to write output values to
`compute_policy` : Bool, optional (default=false)
                   Whether or not to compute policy function
"""

# One time bellman updating.
function bellman_operator_diy(w::Vector,grid::Vector,β::AbstractFloat,u::Function,f::Function,shocks::Vector,Tw::Vector = similar(w);compute_policy::Bool = false)
  #=== Apply linear interpolation to w.
  Then grid, a discrete state space, works as an approximation of continuum state space! ===#

  w_func = LinInterp(grid,w)
  #=== If function request return of policy function, then one should create a vector
  to store the policy function. The state space of policy function is the same as state space,
  and therefore the same as domain of value function===#
  if compute_policy
    σ = similar(w)
  end

  #=== Bellman operator,essentially it is a mapping ===#
  for (i,y) in enumerate(grid)
    objective(c) = - u(c) - β * mean(w_func.(f(y-c) .* shocks))
    res = optimize(objective,1e-10,y)

    if compute_policy
      σ[i] = res.minimizer
    end
    Tw[i] = - res.minimum
  end

  if compute_policy
    return Tw,σ
  else
    return Tw
  end
end

# The closed-form case! One could make a test later.
α = 0.4
β = 0.96
μ = 0
s = 0.1

c1 = log(1-α*β) / (1-β)
c2 = (μ + α*log(α*β))/(1-α)
c3 = 1/(1-β)
c4 = 1/(1-α*β)
# Utility function
u(c) = log(c)
u_prime(c) =1/c

# Deterministic part of production function
f(k) = k^α

f_prime(k) = α* k^(α-1)

c_star(y) = (1-α*β)*y

v_star(y) = c1 + c2*(c3-c4) + c4*log(y)

grid_max = 4         # Largest grid point
grid_size = 200      # Number of grid points
shock_size = 250     # Number of shock draws in Monte Carlo integral

grid_y = collect(linspace(1e-5, grid_max, grid_size))
shocks = exp.(μ + s * randn(shock_size))

using PyPlot

w = bellman_operator_diy(v_star.(grid_y),
                     grid_y,
                     β,
                     log,
                     k -> k^α,
                     shocks)

fig, ax = subplots(figsize=(9, 5))

ax[:set_ylim](-35, -24)
ax[:plot](grid_y, w, lw=2, alpha=0.6, label=L"$Tv^*$")
ax[:plot](grid_y, v_star.(grid_y), lw=2, alpha=0.6, label=L"$v^*$")
ax[:legend](loc="lower right")

show()

######################################
# another experiment.
# test iteration performance
# This figure plots first 36 iteration of bellman operator.
######################################
w = 5* log.(grid_y) # Initial guess of the value function
n = 35
fig, ax = subplots(figsize=(9,6))

ax[:set_ylim](-50,10)
ax[:set_xlim](minimum(grid_y),maximum(grid_y))
lb = "Initial condition"
jet = ColorMap("jet")
ax[:plot](grid_y,w,color=jet(0),lw=2,alpha=0.6,label=lb)
for i in 1:n
  w=bellman_operator_diy(w,
  grid_y,
  β,
  log,
  k->k^α,
  shocks)  # update w: a recursive expression for w

  ax[:plot](grid_y,w,color=jet(i/n),lw=2,alpha=0.6)
end
lb = "True value function"
ax[:plot](grid_y,v_star.(grid_y),"k-",lw=2,alpha=0.8,label=lb)
ax[:legend](loc="lower right")

##########################
# Solve this dynamic programing problem via iteration
##########################
function solve_optgrowth(initial_w;
  tol::AbstractFloat=1e-6,
  max_iter::Integer=500)

  w = initial_w
  error = tol+1
  i = 0
  # One memory free method is creating a new storage array for bellman operator
  # Allocation and speeds code up
  w_new = similar(grid_y)  # the size as state space

  # Iterate to find solution
  while (error > tol)&&(i<max_iter)
    w_new = bellman_operator_diy(w,
    grid_y,
    β,
    log,
    k->k^α,
    shocks)  # update w: a recursive expression for w
    error = maximum(abs,w_new - w)
    w = w_new
    i += 1
  end
  println("Iteration",i)
  return w
end

# Then one could make a test by plotting it against the true value ("True" comes from theory: reduced form solution)
initial_w = 5*log.(grid_y)
v_star_approx=  solve_optgrowth(initial_w)

fix,ax = subplots(figsize = (9,5))
ax[:set_ylim](-35,-24)
ax[:plot](grid_y,v_star_approx,lw=2,alpha=0.6,label="Approximate value function")
ax[:plot](grid_y,v_star.(grid_y),lw=2,alpha=0.6,label="True value function")
ax[:legend](loc="lower right")


# One could directly call compute fixed point function in QuantEcon.
# One argument is bellman operator, essentially a contraction mapping

import QuantEcon: compute_fixed_point

Tw= similar(grid_y)
initial_w = 5*log.(grid_y)

bellman_operator_diy(w)= bellman_operator_diy(w,grid_y,β,log,k->k^α,shocks)

v_star_approx2 = compute_fixed_point(bellman_operator_diy,initial_w,max_iter=500,verbose=2,print_skip=10,err_tol=1e-5)

fig,ax = subplots(figsize=(9,5))
ax[:set_ylim](-35,-24)
ax[:plot](grid_y,v_star_approx2,lw=2,alpha=0.6,label="approximate value function")
ax[:plot](grid_y,v_star_approx,lw=2,alpha=0.6,label="200 iterations value function")
ax[:plot](grid_y,v_star.(grid_y),lw=2,alpha=0.6,label="true value function")
ax[:legend](loc="lower right")
show()

v_star_approx0 = v_star.(grid_y)
