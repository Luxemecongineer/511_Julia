# Sen Lu, This file is about how to do optimization in Julia
#--- Roots
using Roots
f(x) = sin(4*(x-1/4))+ x+ x^20 -1
g(x) = f(x) + 0.7
# One common root-finding algorithm is the Newton-Raphson method
# Newton method is implemented with the function and initial guess
newton(f,0.2)
newton(f,0.7)

fzero(f,0,1)

#--- For univariate, constrained minimization problem, call optimize()
using Optim

x = optimize(x -> x^2, -1.0, 1.0) # objective function f(x) = x^2
println(x)

#---
using Optim
rosenbrock(x) = (1.0 -x[1])^2 + 100.0 * (x[2]-x[1]^2)^2
result = optimize(rosenbrock, zeros(2),BFGS())

#--- For integration, especially for inner loop, better to use quantecon library
using QuantEcon
nodes, weights = qnwlege(65, -2pi,2pi);
g(x) = cos.(x)
integral = do_quad(g, nodes, weights)
# compare this with QuadGK.quadgk
# using QuadGK
# @time quadgk(g,-2pi,2pi)
@time do_quad(g, nodes, weights)
