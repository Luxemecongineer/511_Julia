# Sen Lu
cd("C:\\working\\cs\\Econometrics\\511_Julia\\Julia_intro\\SingleAgentModels")

#--- Test 1  test of importing modules.
# Notice that one should call with the name of module.
include("MJS_Module.jl")
using MJS_module


x = 1.0
y = MJS_module.test_m1(x)
println(y)
pwd()


#--- Test 2   test of importing from another dir.
include("C:\\working\\cs\\Econometrics\\511_Julia\\test_module.jl")
using MyTestModule
println(MyTestModule.x())

#--- Plots the result. one could visually obtains the reservation wage.
# Plot reservation wage and value function
include("MJS_Module.jl")
using MJS_module
using Plots, LaTeXStrings
pyplot()
# request the default exogenous parameters.
mcm = MJS_module.McCallModel()
V,U = MJS_module.solve_McCall_Model(mcm)
# create a vector which has the same length as V (not necessary, just for convenience of plots), to draw a picture.
U_vec = U .* ones(length(mcm.w_vec))

plot(mcm.w_vec,
    [V U_vec],
    lw=2,
    α = 0.7,
    label = [L"$V$" L"$U$"])
gui()


"""
Computes the reservation wage of an instance of the McCall model
by finding the smallest w such that V(w) > U.

If V(w) > U for all w, then the reservation wage w_bar is set to
the lowest wage in mcm.w_vec.

If v(w) < U for all w, then w_bar is set to np.inf.

Parameters
----------
mcm : an instance of McCallModel
return_values : bool (optional, default=false)
    Return the value functions as well

Returns
-------
w_bar : scalar
    The reservation wage

"""
#--- Calculate the reservation wage
include("MJS_Module.jl")
using MJS_module

# # Notice here, when call the type from extra modules, one also need to call with the name of modules.
# function compute_rw(mcm::MJS_module.McCallModel; return_values::Bool=false)
#     V,U = MJS_module.solve_McCall_Model(mcm)
#     w_idx = searchsortedfirst(V-U,0)
#
#     if w_idx == length(V)
#         w_bar = inf
#     else
#         w_bar = mcm.w_vec[w_idx]
#     end
#
#     if return_values == false
#         return w_bar
#     else
#         return w_bar,V,U
#     end
# end

mcm = MJS_module.McCallModel()
MJS_module.compute_rw(mcm)

#--- Characterize the relation between reservation and other exogenous variables
include("MJS_Module.jl")
using MJS_module
using Plots, LaTeXStrings
pyplot()


grid_size = 25
c_vals = linspace(2,12,grid_size)
# For each hypothetical unemployment compensation, return a wage bar
w_bar_vals = similar(c_vals)

mcm = MJS_module.McCallModel()

for (i,c) in enumerate(c_vals)
    # In inner loop, each loop should modify default value stores in container
    mcm.c = c
    w_bar = MJS_module.compute_rw(mcm)  # use new value to compute tmp reservation wage.
    w_bar_vals[i] = w_bar
end


plot(c_vals,
    w_bar_vals,
    lw=2,
    α=0.7,
    xlabel="unemployment compensation",
    ylabel="reservation wage",
    label=L"$\bar{w}$ as a function of $c$")
gui()
#--- Similar method, consider job search offer
include("MJS_Module.jl")
using MJS_module
using Plots, LaTeXStrings
pyplot()

grid_size = 25
γ_vals = linspace(0.05,0.95,grid_size)
# For each hypothetical unemployment compensation, return a wage bar
w_bar_vals_2 = similar(γ_vals)

mcm = MJS_module.McCallModel()

for (i,γ) in enumerate(γ_vals)
    # In inner loop, each loop should modify default value stores in container
    mcm.γ = γ
    w_bar = MJS_module.compute_rw(mcm)  # use new value to compute tmp reservation wage.
    w_bar_vals_2[i] = w_bar
end


plot(γ_vals,
    w_bar_vals_2,
    lw=2,
    α=0.7,
    xlabel="job offer rate",
    ylabel="reservation wage",
    label=L"$\bar{w}$ as a function of $\gamma$")
gui()
