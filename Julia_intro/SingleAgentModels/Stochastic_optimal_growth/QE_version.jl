#=

@authors : Spencer Lyon, John Stachurski

=#

using QuantEcon
using Optim


"""
The approximate Bellman operator, which computes and returns the
updated value function Tw on the grid points.  An array to store
the new set of values Tw is optionally supplied (to avoid having to
allocate new arrays at each iteration).  If supplied, any existing data in
Tw will be overwritten.

#### Arguments

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
function bellman_operator(w::Vector,
                          grid::Vector,
                          β::AbstractFloat,
                          u::Function,
                          f::Function,
                          shocks::Vector,
                          Tw::Vector = similar(w);
                          compute_policy::Bool = false)

    # === Apply linear interpolation to w === #
    w_func = LinInterp(grid, w)

    if compute_policy
        σ = similar(w)
    end

    # == set Tw[i] = max_c { u(c) + β E w(f(y  - c) z)} == #
    for (i, y) in enumerate(grid)
        objective(c) = - u(c) - β * mean(w_func.(f(y - c) .* shocks))
        res = optimize(objective, 1e-10, y)

        if compute_policy
            σ[i] = res.minimizer
        end
        Tw[i] = - res.minimum
    end

    if compute_policy
        return Tw, σ
    else
        return Tw
    end
end


α = 0.4
β = 0.96
μ = 0
s = 0.1

c1 = log(1 - α * β) / (1 - β)
c2 = (μ + α * log(α * β)) / (1 - α)
c3 = 1 / (1 - β)
c4 = 1 / (1 - α * β)

# Utility
u(c) = log(c)

u_prime(c) = 1 / c

# Deterministic part of production function
f(k) = k^α

f_prime(k) = α * k^(α - 1)

# True optimal policy
c_star(y) = (1 - α * β) * y

# True value function
v_star(y) = c1 + c2 * (c3 - c4) + c4 * log(y)

grid_max = 4         # Largest grid point
grid_size = 200      # Number of grid points
shock_size = 250     # Number of shock draws in Monte Carlo integral

grid_y = collect(linspace(1e-5, grid_max, grid_size))
shocks = exp.(μ + s * randn(shock_size))

using PyPlot
import QuantEcon: compute_fixed_point

Tw = similar(grid_y)
initial_w = 5 * log.(grid_y)

bellman_operator(w) = bellman_operator(w,
                                       grid_y,
                                       β,
                                       log,
                                       k -> k^α,
                                       shocks)

v_star_approx = compute_fixed_point(bellman_operator,
                                    initial_w,
                                    max_iter=500,
                                    verbose=2,
                                    print_skip=10,
                                    err_tol=1e-5)

fig, ax = subplots(figsize=(9, 5))
ax[:set_ylim](-35, -24)
ax[:plot](grid_y, v_star_approx, lw=2, alpha=0.6, label="approximate value function")
ax[:plot](grid_y, v_star.(grid_y), lw=2, alpha=0.6, label="true value function")
ax[:legend](loc="lower right")
show()


Tw = bellman_operator(v_star_approx,
                         grid_y,
                         β,
                         log,
                         k -> k^α,
                         shocks;
                         compute_policy=false)

fig,ax = subplots(figsize=(9,5))
ax[:set_ylim](-35, -24)
ax[:plot](grid_y, v_star_approx, lw=2, alpha=0.6, label="approximate value function")
ax[:plot](grid_y, Tw, lw=2, alpha=0.6, label="true value function")
ax[:legend](loc="lower right")

Tw, σ = bellman_operator(v_star_approx,
                         grid_y,
                         β,
                         log,
                         k -> k^α,
                         shocks;
                         compute_policy=true)


cstar = (1 - α * β) * grid_y

fig, ax = subplots(figsize=(9, 5))
ax[:plot](grid_y, σ, lw=2, alpha=0.6, label="approximate policy function")
ax[:plot](grid_y, cstar, lw=2, alpha=0.6, label="true policy function")
ax[:legend](loc="lower right")
show()
