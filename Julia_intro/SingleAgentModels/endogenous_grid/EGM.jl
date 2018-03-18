# Sen Lu. Example comes from Quantecon.

using QuantEcon

#== Julia would report invalid syntax,
when define the type of arguments of a function: Function -> function.
==#

"""
The approximate Coleman opeartor, update using the endogenous grid method.

Parameters:
-------
g:: Function
    The current guess of the policy function.
K_grid::AbstractVector
    The set of *exogenous* grid points, for capital k = y -c
β::AbstractFloat
    The discount factor
u_prime::Function
    The derivative u'(c) of the utility function.
u_prime_inv::Function
    The inverse of u'   (which is assumed to be existed)
f::Function
    The production function
f_prime::Function
    The first order derivative of production function,f'(k).
shocks::AbstractVector
    An array(s,1) of draws from the shocks, for Monte Carlo integration (to compute the integration)
"""

function coleman_EGM(g::Function,
    k_grid::AbstractVector,
    β::AbstractFloat,
    u_prime::Function,
    u_prime_inv::Function,
    f::Function,
    f_prime::Function,
    shocks::AbstractVector)

    # Allocate memory for value of consumption on endogenous grid points
    c = similar(k_grid)

    # Solve for updated consumption value.
    for (i,k) in enumerate(k_grid)
        vals = u_prime.(g.(f(k)*shocks)) .* f_prime(k) .*shocks
        c[i] = u_prime_inv(β*mean(vals))
    end

    # Determine endogenous grid
    y = k_grid + c

    # Update policy funciton and return it.
    Kg = LinInterp(y,c)
    Kg_f(x)=Kg(x)
    return Kg_f
end

# re-include the original coleman operator.
function coleman_operator!(g::AbstractVector,
                           grid::AbstractVector,
                           β::AbstractFloat,
                           u_prime::Function,
                           f::Function,
                           f_prime::Function,
                           shocks::AbstractVector,
                           Kg::AbstractVector=similar(g))

    # This function requires the container of the output value as argument Kg

    # Construct linear interpolation object #
    g_func=LinInterp(grid, g)

    # solve for updated consumption value #
    for (i,y) in enumerate(grid)
        function h(c)
            vals = u_prime.(g_func.(f(y - c)*shocks)).*f_prime(y - c).*shocks
            return u_prime(c) - β * mean(vals)
        end
        Kg[i] = brent(h, 1e-10, y-1e-10)
    end
    return Kg
end

# The following function does NOT require the container of the output value as argument
function coleman_operator(g::AbstractVector,
                          grid::AbstractVector,
                          β::AbstractFloat,
                          u_prime::Function,
                          f::Function,
                          f_prime::Function,
                          shocks::AbstractVector)

    return coleman_operator!(g, grid, β, u_prime,
                             f, f_prime, shocks, similar(g))
end

# One could test out the code above.
using PyPlot
using LaTeXStrings

########################
# Create a Model type  #
# Construct a function #
########################

struct Model{TF <: AbstractFloat, TR <: Real, TI <: Integer}
    α::TR              # Productivity parameter
    β::TF              # Discount factor
    γ::TR              # risk aversion
    μ::TR              # First parameter in lognorm(μ, σ)
    s::TR              # Second parameter in lognorm(μ, σ)
    grid_min::TR       # Smallest grid point
    grid_max::TR       # Largest grid point
    grid_size::TI      # Number of grid points
    u::Function        # utility function
    u_prime::Function  # derivative of utility function
    f::Function        # production function
    f_prime::Function  # derivative of production function
    grid::Vector{TR}   # grid
end

"""
construct Model instance using the information of parameters and functional form

arguments: see above

return: Model type instance
"""
function Model(; α::Real=0.65,                      # Productivity parameter
                 β::AbstractFloat=0.95,             # Discount factor
                 γ::Real=1.0,                       # risk aversion
                 μ::Real=0.0,                       # First parameter in lognorm(μ, σ)
                 s::Real=0.1,                       # Second parameter in lognorm(μ, σ)
                 grid_min::Real=1e-6,               # Smallest grid point
                 grid_max::Real=4.0,                # Largest grid point
                 grid_size::Integer=200,            # Number of grid points
                 u::Function= c->(c^(1-γ)-1)/(1-γ), # utility function
                 u_prime::Function = c-> c^(-γ),    # u'
                 f::Function = k-> k^α,             # production function
                 f_prime::Function = k -> α*k^(α-1) # f'
                 )

    grid=collect(linspace(grid_min, grid_max, grid_size))

    if γ == 1   # when γ==1, log utility is assigned
        u_log(c) = log(c)
        m = Model(α, β, γ, μ, s, grid_min, grid_max,
                grid_size, u_log, u_prime, f, f_prime, grid)
    else
        m = Model(α, β, γ, μ, s, grid_min, grid_max,
                  grid_size, u, u_prime, f, f_prime, grid)
    end
    return m
end

# Then one could generate an instance
mlog = Model(γ=1.0)

shock_size = 250
shocks = exp.(mlog.μ + mlog.s * randn(shock_size))

# Generate the true function, by the theory.
c_star(y)=(1 - mlog.α * mlog.β) * y

# == Some useful constants == #
ab = mlog.α * mlog.β
c1 = log(1 - ab) / (1 - mlog.β)
c2 = (mlog.μ + mlog.α * log(ab)) / (1 - mlog.α)
c3 = 1 / (1 - mlog.β)
c4 = 1 / (1 - ab)

v_star(y)=c1 + c2 * (c3 - c4) + c4 * log(y)

# Following function could visually check whether the true function is indeed the fixed point.
function verify_true_policy(m::Model,
                            shocks::AbstractVector,
                            c_star::Function)
    k_grid = m.grid
    c_star_new = coleman_EGM(c_star,
            k_grid, m.β, m.u_prime, m.u_prime, m.f, m.f_prime, shocks)
    fig, ax = subplots(figsize=(9, 6))

    ax[:plot](k_grid, c_star.(k_grid), label=L"optimal policy $c^*$")
    ax[:plot](k_grid, c_star_new.(k_grid), label=L"$Kc^*$")
    ax[:legend](loc="upper left")
    show()
end

verify_true_policy(mlog,shocks,c_star)

# Let's check the convergence of coleman_EGM opeartor.
g_init(x) = x
n = 15
function check_convergence(m::Model,
                           shocks::AbstractVector,
                           c_star::Function,
                           g_init::Function,
                           n_iter::Integer)
    k_grid = m.grid
    g = g_init
    fig, ax = subplots(figsize = (9, 6))
    jet = ColorMap("jet")
    plot(m.grid, g.(m.grid),
            color=jet(0), lw=2, alpha=0.6, label=L"initial condition $c(y) = y$")
    for i in 1:n_iter
        new_g = coleman_EGM(g, k_grid,
                            m.β, m.u_prime, m.u_prime, m.f, m.f_prime, shocks)
        g = new_g
        ax[:plot](k_grid,new_g.(k_grid), alpha=0.6, color=jet(i / n_iter), lw=2)
    end

    ax[:plot](k_grid, c_star.(k_grid),
                "k-", lw=2, alpha=0.8, label= L"true policy function $c^*$")
    ax[:legend](loc="upper left")
    show()
end

check_convergence(mlog, shocks, c_star, g_init, n)

# Then one could use a crra instance to compare this EGM operator and previous operator.
# create new Model instance.
mcrra = Model(α = 0.65, β = 0.95, γ = 1.5)
u_prime_inv(c) = c^(-1/mcrra.γ)

function compare_clock_time(m::Model,
                            u_prime_inv::Function;
                            sim_length::Integer=20)
    k_grid = m.grid
    crra_coleman(g) = coleman_operator(g, k_grid,
                            m.β, m.u_prime, m.f, m.f_prime, shocks)
    crra_coleman_egm(g) = coleman_EGM(g, k_grid,
                            m.β, m.u_prime, u_prime_inv, m.f, m.f_prime, shocks)

    print("Timing standard Coleman policy function iteration")
    g_init = k_grid
    g = g_init
    @time begin
        for i in 1:sim_length
            new_g = crra_coleman(g)
            g = new_g
        end
    end

    print("Timing policy function iteration with endogenous grid")
    g_init_egm(x) = x
    g = g_init_egm
    @time begin
        for i in 1:sim_length
            new_g = crra_coleman_egm(g)
            g = new_g
        end
    end
    return nothing
end
compare_clock_time(mcrra, u_prime_inv, sim_length=20)
