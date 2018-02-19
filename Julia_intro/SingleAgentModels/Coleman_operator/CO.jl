# Sen Lu. example from QuantEcon :https://lectures.quantecon.org/jl/coleman_policy_iter.html

using QuantEcon
"""
g:input policy function
grid: grid points
β: discount factor
u_prime: derivative of utility function
f:production function
f_prime: derivative of production function
shocks:: shock draws, used for Monte Carlo integration to compute expectation
Kg:output value is stored while do contraction mapping
"""
function coleman_operator!(g::AbstractVector,
    grid::AbstractVector,
    β::AbstractFloat,
    u_prime::Function,
    f::Function,
    f_prime::Function,
    shocks::AbstractVector,
    Kg::AbstractVector=similar(g))

    #This function requires the container of the output value as argument Kg, to save memory
    # Construct linear interpolation object
    g_func = LinInterp(grid, g)
    # solve for updated consumption value
    for (i,y) in enumerate(grid)
        function h(c)
            vals = u_prime.(g_func.(f(y-c)*shocks)).*f_prime(y-c).*shocks
            return u_prime(c)-β*mean(vals)
            # The return value is combination of equations (2) and (5)
        end
        Kg[i] = brent(h,1e-10,y-1e-10)
    end
    return Kg
end

# The following function doesn't require the container of the output value as argument
function coleman_operator(g::AbstractVector,
    grid::AbstractVector,
    β::AbstractFloat,
    u_prime::Function,
    f::Function,
    f_prime::Function,
    shocks::AbstractVector)

    return coleman_operator!(g ,grid,β,u_prime,f,f_prime,shocks,similar(g))
end


# To compare with value function iteration
# incluede previous bellman operator here

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
function bellman_operator_test(w::Vector,
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


# Then one could use this two different operator to do test!
# Create a struct
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
Construct Model instance using exogenous information of parameters and function form arguments: see the struct above
Return: a Model type instance
"""
# Notice that, using function to create container here, just convenience of changing function form(Not just simplely parameters)
function Model(;α::Real=0.65,
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
    grid = collect(linspace(grid_min,grid_max,grid_size))

    if γ==1 #when γ==1 the function form changed, that is the reason function is used here
        u_log(c) = log(c)
        m = Model(α, β, γ, μ, s, grid_min, grid_max,
        grid_size, u_log, u_prime, f, f_prime, grid) # here parameters are default in function.
    else
        m = Model(α, β, γ, μ, s, grid_min, grid_max,
        grid_size, u, u_prime, f, f_prime, grid)
    end
    return m
end

# Generate an instance
m = Model(γ=1.0)

# We also need some shock draws for Monte Carlo integration
shock_size = 250
shocks = collect(exp.(m.μ + m.s*randn(shock_size)))

using PyPlot
using LaTeXStrings
"""
This function plots a specified policy function and map of the policy function
If they are the samej, the policy function is true

m: instance of Model type, storing all parameters.
shocks: shocks for Monte Carlo integration
c_star: True policy function
"""
function verify_true_policy(m::Model,
    shocks::AbstractVector,
    c_star::AbstractVector)
    # Compute (Kc^*)
    c_star_new = coleman_operator(c_star,
    m.grid,m.β,m.u_prime,m.f,m.f_prime,shocks)
    #Plot c^* and Kc^*
    fig,ax = subplots()
    ax[:plot](m.grid, c_star, label=L"Optimal Policy $c^*$")
    ax[:plot](m.grid, c_star_new, label=L"$Kc^*$")
    ax[:legend](loc="upper left")
end

# According to the theory of reduced form policy function
# To discretize the function, via obtain a grid of its values
c_star = (1-m.α*m.β)*m.grid
verify_true_policy(m,shocks,c_star)
# Actually, this just test if c_star is the fixed point.
# Following ganna be the test about convergence.
"""
This function (write everything as a function!) plots the resulting policy function of each iteration and
    compare it with the true one.
m: an instance of Model type, storing all parameters.
shocks::shocks for Monte Carlo integration.
c_star: true policy function, as a testable object.
n_iter: number of iterations.
g_init:initial guess of policy function.
"""
function check_convergence(m::Model,
    shocks::AbstractVector,
    c_star::AbstractVector,
    g_init::AbstractVector;
    n_iter::Integer=15)

    fig,ax=subplots(figsize=(9,6))
    jet = ColorMap("jet")
    g=g_init;
    # first plot:
    ax[:plot](m.grid,g,color=jet(0),lw=2,alpha=0.6,
    label=L"initial condition $c(y) = y$")
    for i =1:n_iter
        new_g = coleman_operator(g,m.grid,m.β,m.u_prime,m.f,m.f_prime,shocks)
        g = new_g # recursion~
        ax[:plot](m.grid,g,color=jet(i/n_iter),lw=2,alpha=0.6)
    end
    ax[:plot](m.grid,c_star,"k-",lw=2,alpha=0.8,label=L"True policy function $c^*$")
    ax[:legend](loc="upper left")
end

# Plots whether it converge
check_convergence(m,shocks,c_star,m.grid,n_iter=20)

function iterate_updating(func::Function,
    arg_init::AbstractVector;
    sim_length::Integer=20)
    # Create a tmp var arg to store the recursive return
    # Create this before loop, it would save memory.
    arg=arg_init;
    for i=1:sim_length
        new_arg = func(arg)
        arg = new_arg
    end
    return arg
end

"""
This function compares the gap between true policy and policy function
derived from policy function iteration and value function iteration

m: Model instance
shocks: shocks for Monte Carlo integration
g_init: initial policy function
w_init: initial value function
sim_length: number of iterations
"""
function compare_error(m::Model,
    shocks::AbstractVector,
    g_init::AbstractVector,
    w_init::AbstractVector;
    sim_length::Integer=20)

    fig,ax = subplots()
    jet = ColorMap("jet")

    g,w = g_init,w_init
    g_test = similar(g)
    ############################

    # use same model instance to call two different operators.
    # Following two functions just simplify the notation (too many arguments) of operator functions.
    bellman_single_arg(w) = bellman_operator_test(w,m.grid,m.β,m.u,m.f,shocks)
    coleman_single_arg(g) = coleman_operator(g,m.grid,m.β,m.u_prime,m.f,m.f_prime,shocks)
    g_test = iterate_updating(coleman_single_arg,g_init,sim_length=sim_length)
    w = iterate_updating(bellman_single_arg,w_init,sim_length=sim_length)
    # One could call once more bellman operator with argument compute policy-true, it would return associated policy function
    new_w,vf_g = bellman_operator_test(w,m.grid,m.β,m.u,m.f,shocks,compute_policy=true)

    pf_error = c_star - g_test
    vf_error = c_star - vf_g


    ax[:plot](m.grid,0.*m.grid,"k-",lw=1)
    ax[:plot](m.grid,pf_error, lw=2,alpha=0.6,label = "Policy iteration error")
    ax[:plot](m.grid,vf_error, lw=2,alpha=0.6,label = "value iteration error")
    ax[:legend](loc="lower left")
end
m
compare_error(m,shocks,m.grid,m.u.(m.grid),sim_length=300)
