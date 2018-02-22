# Sen Lu. Example from QuantEcon.
# This script, just a example of how to create density with a weighted posterior probability.

using Plots
using LaTeXStrings
using Distributions
pyplot()

# Create this two distribution (discretized beta distribution)
p_m1 = linspace(0,1,50)
f0 = clamp.(pdf(Beta(1,1),p_m1),1e-8,Inf)
f0=f0 / sum(f0) #Actually this is vector operator
f1 = clamp.(pdf(Beta(9,9),p_m1),1e-8,Inf)
f1= f1 / sum(f1)    #Actually this is vector operator


a = plot([f0 f1],
    xlabel = L"$k$ Values",
    ylabel = L"Probability of $z_k$",
    labels = [L"$f_0$", L"$f_1$"],
    linewidth = 2,
    ylims=[0.;0.07],
    title="Original Distributions")

mix = Array{Float64}(50,3)
labels = Array{String}(1,3)
p_k = [0.25;0.5;0.75]
for i in 1:3
    mix[:,i] = p_k[i] * f0 + (1-p_k[i])* f1
    labels[1,i] = string(L"$p_k$ = ", p_k[i])
end

b = plot(mix,
    xlabel = L"$k$ Values",
    ylabel = L"Probability of $z_k$",
    labels = labels,
    linewidth = 2,
    ylims=[0.;0.06],
    title = "mixture of Original Distributions")

plot(a,b,layout=(2,1), size = (600,800))

gui()
