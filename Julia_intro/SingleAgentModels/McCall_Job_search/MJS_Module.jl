# Sen Lu. This example comes from QuantEcon
# https://lectures.quantecon.org/jl/mccall_model.html

#===
    this is a single agent model. Probably one of the simplest leading example of dynamic programing problem in Economics
    Model description:
    1. player
        There is one continuum of worker.
    2. Government
        Government is not a strategic player in this model. It could be treated as an exogeneous unemployment insurance payment plan.
    3. timing and decisions
        For any given fixed worker,
        (a) if this worker is currently employed (with a wage offer w), then in each period she would receive payment w and consume them all.
        (b) if this worker is currently unemployed, at the beginning of each period, she would go to the job market, and randomly draw a job offer from an exogenous distribution with support [̄w, ̲w];
            Then worker has two choices:
                (1) accept this job offer, and take this job afterwards.
                (2) reject this job offer, and receive one period unemployment insurance. Then enter next period as an unemployed worker.
    4. Job termination
        When employed, worker faces a constant probability of being fired at the end of each period.
    5. probability of getting a job offer
        Assume unemployed worker get a job offer with a γ probability

    The main points of dynamic programing:
        (1) Assuming that you know the answer.
        (2) Write down the necessary conditions that the optimal answer should satisfy.
        (3) Essentially, one just tries to write this model in a hidden Markovian form.

    For a given model, there are multiple markovian ways to write it.
        In this case, the optimal decision should satisfy the following Bellman system:
            denote the expected value of a offer draw (w) at the beginning of a period as V(w), and denote the expected value of being unem-ployed as U.
            (1) V(w) = u(w) + β[(1-α)V(w) + αU]
            (2) U = u(c) + β E[max{U,V(w′)}]

===#

module MJS_module

# A test function.
function test_m1(x::Real)
    return 2*x
end

using Distributions

# A default utility function
function u(c::Real, σ::Real)
    if c>0
        return (c^(1-σ)-1)/(1-σ)
    else
        return -10e6
    end
end

# default wage vector with probability
# In this case, when you start with a exogeneous probability vector, one should set const vars.
const n = 60    # like bins
const default_w_vec = linspace(10,20,n) #wage support
const a,b = 600,400 #shape parameters
const dist = BetaBinomial(n-1, a, b)
const default_p_vec = pdf(dist)


# Create a container that stores the exogeneous primitive
mutable struct McCallModel{TF<:AbstractFloat,TAV<: AbstractVector{TF},TAV2<:AbstractVector{TF}}
    α::TF   #termination rate
    β::TF   #Discount rate
    γ::TF   #Job offer rate
    c::TF   #Unemployment compensation
    σ::TF   #Utility parameters
    w_vec::TAV  #Possible wage value
    p_vec::TAV2 #Probabilities over w_vec

    McCallModel(α::TF = 0.2,
                β::TF = 0.98,
                γ::TF = 0.7,
                c::TF = 6.0,
                σ::TF = 2.0,
                w_vec::TAV = default_w_vec,
                p_vec::TAV2 = default_p_vec) where {TF, TAV, TAV2} =
        new{TF, TAV, TAV2}(α,β,γ,c,σ,w_vec,p_vec)
end

"""
A function to update the Bellman equations. One should vectorized the algorithm
"""
# It is quite allocation free to put V_new and V both in the args.
function update_bellman!{TF<:Real}(mcm::McCallModel,V::AbstractVector{TF},
                                            V_new::AbstractVector{TF},U::Real)
    # just Simplify Notaion, otherwise one have to write mcm.?. That is disturbing.
    α,β,σ,c,γ = mcm.α,mcm.β,mcm.σ,mcm.c,mcm.γ
    for (w_idx, w) in enumerate(mcm.w_vec)
        # w_idx indexes the vector of possible wages
        V_new[w_idx] = u(w,σ) + β*((1-α)*V[w_idx]+ α*U)
    end
    # Another method to update vector value is
    # V_new .= u.(w_vec,σ) .+ (β*(1-α)).*V .+ β*α*U[1]

    U_new = u(c,σ) + β*(1-γ)*U + β*γ*dot(max.(U,V), mcm.p_vec)
    return U_new
end




# This function require the argument satisfy the self-defined type-- McCallModel.
function solve_McCall_Model(mcm::McCallModel;
                            tol::AbstractFloat=1e-6,max_iter::Integer=20000)

    V = ones(length(mcm.w_vec))
    V_new = similar(V)
    U = 1.0
    i = 0
    error = tol + 1.0
    error_1 = tol + 1.0
    error_2 = tol + 1.0

    while error > tol && i <max_iter
        U_new = update_bellman!(mcm,V,V_new,U)
        error_1 = maximum(abs,V_new - V)
        error_2 = abs(U_new - U)
        error = max(error_1, error_2)
        V[:] = V_new
        U = U_new
        i +=1
        # println("Iteration $i")
    end
    println("Iteration $i")
    return V,U
end

function compute_rw(mcm::MJS_module.McCallModel; return_values::Bool=false)
    V,U = MJS_module.solve_McCall_Model(mcm)
    w_idx = searchsortedfirst(V-U,0)

    if w_idx == length(V)
        w_bar = inf
    else
        w_bar = mcm.w_vec[w_idx]
    end

    if return_values == false
        return w_bar
    else
        return w_bar,V,U
    end
end


end
