using Distributions
using Plots
pyplot()

w_max = 2
x = linspace(0, w_max, 200)

G = Beta(3,1.6)
F = Beta(1,1)
plot(x,pdf.(G,x/w_max)/w_max,label="g")
plot!(x,pdf.(F,x/w_max)/w_max,label="f")
gui()
