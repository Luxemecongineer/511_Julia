#Sen Lu. Example comes from QuantEcon.
using Distributions
using QuantEcon.compute_fixed_point, QuantEcon.DiscreteRV, QuantEcon.draw, QuantEcon.LinInterp
using Plots
pyplot()
using LaTeXStrings


expected_loss_choose_0(p::Real,L0::Real)=(1-p)*L0
expected_loss_choose_1(p::Real,L1::Real)=p*L1

"""
This bellman equation essentially test when to stop testing.
"""
# Following function calculate the expected next period value function
function EJ(p::Real, f0::AbstractVector, f1::AbstractVector, J::LinInterp)
    # Get the current distribution that we believe (p*f0 + (1-p)*f1)
    curr_dist = p*f0 + (1-p)*f1

    # Get tomorrow's expected distribution through bayes Law
    tp1_dist = clamp.((p*f0) ./ (p*f0 + (1-p)*f1),0,1)
    # Evaluate the expectation
    EJ = dot(curr_dist, J.(tp1_dist))
    return EJ
end

expected_loss_cont(p::Real, c::Real,
        f0::AbstractVector, f1::AbstractVector,J::LinInterp) =
    c+ EJ(p,f0,f1,J)

"""
Evaluates the value function for a given continuation value function, that is,
    J(p) = min( pL0, (1-p)L1, c + E[J(p')])
Uses linear interpolation between points
"""
function bellman_operator_WF(pgrid::AbstractVector,c::Real,
    f0::AbstractVector, f1::AbstractVector,
    L0::Real, L1::Real, J::AbstractVector)

    m = length(pgrid)
    @assert m == length(J)

    J_out = zeros(m)
    # Vectorization the code to save memory.
    J_interp = LinInterp(pgrid, J)

    for (p_ind, p) in enumerate(pgrid)
        p_c_0 = expected_loss_choose_0(p, L0)
        p_c_1 = expected_loss_choose_1(p, L1)
        p_con = expected_loss_cont(p, c, f0, f1, J_interp)

        J_out[p_ind] = min(p_c_0, p_c_1, p_con)
    end

    return J_out
end

# Create two distributions over 50 values for k
# We are using a discretized beta distribution

p_m1 = linspace(0, 1, 50)
f0 = clamp.(pdf(Beta(1, 1), p_m1), 1e-8, Inf)
f0 = f0 / sum(f0)
f1 = clamp.(pdf(Beta(9, 9), p_m1), 1e-8, Inf)
f1 = f1 / sum(f1)

# To solve
pg = linspace(0, 1, 251)
J1 = compute_fixed_point(x -> bellman_operator_WF(pg, 0.5, f0, f1, 5.0, 5.0, x),
    zeros(length(pg)), err_tol = 1e-6, print_skip=5);

plot(J1)
gui()
