# Sen Lu, example from https://lectures.quantecon.org/jl/wald_friedman.html

"""
This type is used to store the solution to the problem presented in the "Wald Friedman"

Solution
---------------
J: AbstractVector
    Discrete value function that solves the bellman equation.
lb: Real
    Lower cutoff for continuation decision
ub: Real
    Upper cutoff for continuation decision
"""
# Struct just define a type.
mutable struct WFSolution{TAV<: AbstractVector,TR<:Real}
    J::TAV
    lb::TR
    ub::TR
end

"""
This type is used to solve the problem presented in the "Wald Friedman"

Parameters
-----------------
c: Real
    cost of postponing decision
L0: Real
    cost of choosing model 0 when the truth is model 1
L1: Real
    cost of choosing model 1 when the truth is model 0
f0: AbstractVector
    A finite state probability distribution
f1: AbstractVector
    A finite state probability distribution
m: Integer
    Number of points to use in function approximation
"""
# This struct define another type, which include one self-defined type.
struct WaldFriedman{TR<:Real, TI<: Integer,
                    TAV1<:AbstractVector,TAV2<:AbstractVector}
    c::TR
    L0::TR
    L1::TR
    f0::TAV1
    f1::TAV1
    m::TI
    pgrid::TAV2
    sol::WFSolution #WFSolution is a self-defined a type, that stores solution of the problem.
end

function WaldFriedman{TR<:Real,TAV<:AbstractVector}(c::TR, L0::TR, L1::TR,
    f0::TAV,f1::TAV;m::Integer=25)
    pgrid = linspace(0.0,1.0,m)
    # Renormalize the distributions so nothing is too small
    f0 = clamp.(f0,1e-8,1-1e-8)
    f1 = clamp.(f1,1e-8,1-1e-8)
    f0 = f0/sum(f0)
    f1 = f1/sum(f1)
    J = zeros(m)
    lb = 0.
    ub = 0.

    WaldFriedman(c,L0,L1,f0,f1,m,pgrid,WFSolution(J,lb,ub))
end

"""
Following function takes a value for the probability (belief) with which correct
    model is model 0 and returns the mixed distribution that corresponds with the belief.
"""
current_distribution(wf::WaldFriedman, p::Real) = p*wf.f0 + (1-p)*wf.f1

"""
The following function take a value for p, and a realization of random variable and
    calculate the updated probability using Bayes rule.
"""
function bayes_update_k(wf::WaldFriedman, p::Real, k::Integer)
    f0_k = wf.f0[k]
    f1_k = wf.f1[k]

    p_tp1 = p*f0_k / (p*f0_k + (1-p)*f1_k)

    return clamp(p_tp1,0,1)
end

"""
The following function returns a new value for p for each realization of the random var.
"""
bayes_update_all(wf::WaldFriedman, p::Real)=
    clamp.(p*wf.f0 ./ (p*wf.f0 + (1-p)*wf.f1), 0, 1)

"""
For a given probability specify the cost of accepting model 0
"""
payoff_choose_f0(wf::WaldFriedman, p::Real) = (1-p)*wf.L0
