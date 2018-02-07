using PyPlot

x = linspace(0, 2, 100)
y = x.^2
z = x.^3

plot(x, x)
plot(x, y)
plot(x, z)

xlabel("X Axis")
ylabel("Y Axis")
grid("on")
title("Test time")
# title("Simple Plot")

# PyPlot.legend()
show()
