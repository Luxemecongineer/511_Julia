using Distributions
using PyPlot

pygui()
u = Uniform()
fig, ax = subplots()
x = linspace(-4, 4, 150)
# grid("on")
for i in 1:3
    # == Compute normal pdf from randomly generated mean and std == #
    m, s = rand(u) * 2 - 1, rand(u) + 1
    d = Normal(m, s)
    y = pdf(d, x)
    # == Plot current pdf == #
    ax[:plot](x, y, linewidth=2, alpha=0.6, label="draw $i")
end
ax[:legend]()
