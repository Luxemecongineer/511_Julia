#Sen Lu. Replicate the example from QuantEcon, https://lectures.quantecon.org/jl/ifp.html

using QuantEcon
using Optim

# Create a type for the model, i.e. call ConsumerP, that stores model primitives.

# Utility function
u(x) = log(x)   #utility functoin
du(x) = 1/x #marginal utility function

"""
Income fluctuation problem
#### Fields:
r::Real -   Strictly positive interest rate
R::Real -   The interest rate (>1)
β::Real -   Discount rate in (0,1)
b::Real -   The exogenous borrowing constraint
Π::Matrix{T}    where T<:Real   -   Transition matrix for "z"
z_vals::Vector{T}   where T<:Real   -   Levels of productivity.
asset_grid::AbstractArray   -   Grid of asset values
"""

struct ConsumerP{T<:Real}
    r::T
    R::T
    β::T
    b::T
    Π::Matrix{T}
    z_vals::Vector{T}
    asset_grid::AbstractArray
end

# Create a function that personalized some specific primitives.
function ConsumerP(;r=0.01,
    β=0.96,
    Π=[0.6 0.4; 0.05 0.95],
    z_vals=[0.5,1.0],
    b=0.0,
    grid_max=16,
    grid_size=50)

    R = 1 + r
    asset_grid = linspace(-b,grid_max,grid_size)

    ConsumerP(r, R, β, b, Π, z_vals, asset_grid)
end

ConsumerP()

"""
Apply the Bellman operator for a given model and initial guess

####    Arguments

cp::ConsumerP   -   An instance of ConsumerP, a primitive model type.
v::Matrix   -   Current guess for value function. (there are two state variables, and so as value function domain)
out::Matrix -   Storage for output.
ret_policy::Bool(false) -   Toggles return of value or policy functions.

####    Returns
None, 'out' is updated in place (one memory free method of coding)
If ret_policy==true, out is filled with the policy function,
otherwise the value function is stored in out.
"""

function bellman_operator_diy!(cp::ConsumerP,
    V::Matrix,
    out::Matrix;
    ret_policy::Bool=false)

    # First simplify the notation.
    R,Π,β,b = cp.R, cp.Π, cp.β, cp.b
    asset_grid,z_vals = cp.asset_grid,cp.z_vals
    z_idx = 1:length(z_vals)

    # value function when the shock index is z_i
    vf= interp(asset_grid, V)

    opt_lb = 1e-8

    # solve for RHS of Bellman equation
    for (i_z, z) in enumerate(z_vals)
        for (i_a, a) in enumerate(asset_grid)

            function obj(c)
                EV = dot(vf.(R*a+z-c,z_idx),Π[i_z,:])   #compute expectation
                return -u(c)-β*EV
            end
            res = optimize(obj,opt_lb, R .* a .+ z .+ b)
            c_star = Optim.minimizer(res)

            if ret_policy
                out[i_a,i_z] = c_star
            else
                out[i_a,i_z] = - Optim.minimum(res)
            end

        end
    end
    out
end

# Following function is standard way to define silent call.
bellman_operator_diy(cp::ConsumerP, V::Matrix; ret_policy=false) =
    bellman_operator_diy!(cp, V, similar(V); ret_policy=ret_policy)

"""
Extract the greedy policy (policy function) of the model.

##### Arguments

- `cp::CareerWorkerProblem` : Instance of `CareerWorkerProblem`
- `v::Matrix`: Current guess for the value function
- `out::Matrix` : Storage for output

##### Returns

None, `out` is updated in place to hold the policy function

"""
get_greedy!(cp::ConsumerP, V::Matrix, out::Matrix) =
    update_bellman_diy!(cp, V, out, ret_policy=true)

get_greedy(cp::ConsumerP, V::Matrix) =
    update_bellman_diy(cp, V, ret_policy=true)

"""
The approximate Coleman operator.

Iteration with this operator corresponds to policy function
iteration. Computes and returns the updated consumption policy
c.  The array c is replaced with a function cf that implements
univariate linear interpolation over the asset grid for each
possible value of z.

##### Arguments

- `cp::CareerWorkerProblem` : Instance of `CareerWorkerProblem`
- `c::Matrix`: Current guess for the policy function
- `out::Matrix` : Storage for output

##### Returns

None, `out` is updated in place to hold the policy function

"""

function coleman_operator_diy!(cp::ConsumerP, c::Matrix, out::Matrix)
    # simplify names, set up arrays
    R, Π, β, b = cp.R, cp.Π, cp.β, cp.b
    asset_grid, z_vals = cp.asset_grid, cp.z_vals
    z_idx = 1:length(z_vals)
    gam = R * β

    # policy function when the shock index is z_i
    cf = interp(asset_grid, c)

    # compute lower_bound for optimization
    opt_lb = 1e-8

    for (i_z, z) in enumerate(z_vals)
        for (i_a, a) in enumerate(asset_grid)
            function h(t)
                cps = cf.(R * a + z - t, z_idx) # c' for each z'
                expectation = dot(du.(cps), Π[i_z, :])
                return abs(du(t) - max(gam * expectation, du(R * a + z + b)))
            end
            opt_ub = R*a + z + b  # addresses issue #8 on github
            res = optimize(h, min(opt_lb, opt_ub - 1e-2), opt_ub,
                           method=Optim.Brent())
            out[i_a, i_z] = Optim.minimizer(res)
        end
    end
    out
end

"""
Apply the Coleman operator for a given model and initial value

See the specific methods of the mutating version of this function for more
details on arguments
"""
coleman_operator_diy(cp::ConsumerP, c::Matrix) =
    coleman_operator_diy!(cp, c, similar(c))

# Keep the habit of writing everything in a function.
function initialize(cp::ConsumerP)
    # simplify names, set up arrays
    R, β, b = cp.R, cp.β, cp.b
    asset_grid, z_vals = cp.asset_grid, cp.z_vals
    shape = length(asset_grid), length(z_vals)
    V, c = Array{Float64}(shape...), Array{Float64}(shape...)

    # Populate V and c
    for (i_z, z) in enumerate(z_vals)
        for (i_a, a) in enumerate(asset_grid)
            c_max = R * a + z + b
            c[i_a, i_z] = c_max
            V[i_a, i_z] = u(c_max) ./ (1 - β)
        end
    end

    return V, c
end

cp = ConsumerP()
v,c = initialize(cp)
@time bellman_operator_diy(cp,v);
@time coleman_operator_diy(cp,v);

# Exercise 1
using Plots
pyplot()

function ex1()
    cp = ConsumerP()
    K = 80

    V,c = initialize(cp)
    println("Starting value function iteration")
    # Iterate 80 times
    for i=1:K
        V = bellman_operator_diy(cp,V)
    end
    c1= bellman_operator_diy(cp,V,ret_policy=true)

    V2,c2 = initialize(cp)
    println("Starting policy function iteration")
    for i=1:K
        c2 = coleman_operator_diy(cp,c2)
    end

    plot(cp.asset_grid,c1[:,1], label = "value function iteration")
    plot!(cp.asset_grid,c2[:,1], label = "policy function iteration")
    plot!(xlabel="asset label",ylabel="comsumption (low income)")
    gui()
end

ex1()

# Exercise 2
function ex2()
    pyplot()
    r_vals = linspace(0,0.04,4)
    traces = [] # This array collect the result generated in each inner loop
    legends = []    # For each inner loop, create a corresponding legend. Adding it in inner loop is a better way.
    for r_val in r_vals
        cp = ConsumerP(r = r_val)
        v_init, c_init = initialize(cp)
        c=compute_fixed_point(x->coleman_operator_diy(cp,x), c_init,
        max_iter=150, verbose=false)
        traces = push!(traces, c[:, 1])
        legends = push!(legends,"r=$(round(r_val,3))")
    end
    plot(traces,label=reshape(legends,1,length(legends)))
    plot!(xlabel="asset level",ylabel="consumption (low income)")
    gui()
    return traces
end
println(ex2())


function compute_asset_series(cp; T=500000, verbose=false)
    Π, z_vals, R = cp.Π, cp.z_vals, cp.R  # Simplify names
    z_idx = 1:length(z_vals)
    v_init, c_init = initialize(cp)
    c = compute_fixed_point(x -> coleman_operator_diy(cp, x), c_init,
                            max_iter=150, verbose=false)

    cf = interp(cp.asset_grid, c)

    a = zeros(T+1)
    z_seq = simulate(MarkovChain(Π), T)
    for t=1:T
        i_z = z_seq[t]
        a[t+1] = R * a[t] + z_vals[i_z] - cf(a[t], i_z)
    end
    return a
end

function ex3()
    cp = ConsumerP(r=0.03, grid_max=4)
    a = compute_asset_series(cp)
    histogram(a,nbins=20, leg=false)
    plot!(xlabel="assets", ytics=(-0.05, 0.75))
    gui()
end

ex3()
