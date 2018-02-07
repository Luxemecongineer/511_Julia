using PyPlot
x = linspace(0, 10, 200)
y = sin.(x)
fig, ax = subplots()
ax[:plot](x, y, "r-", linewidth=2, label=L"$y = \sin(x)$", alpha=0.6)
ax[:legend](loc="upper center")
show()
