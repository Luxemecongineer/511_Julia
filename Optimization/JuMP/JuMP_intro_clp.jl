# Sen Lu. Intro to JuMP

using JuMP
using Clp

m = Model(solver = ClpSolver())
@variable(m,0<= x <=2)
@variable(m,0<= y <=30)

@objective(m,:Max, 5x + 3y)
@constraint(m,x+5y<=3.0)
println(m)

status = solve(m)
println("Objective value: ", getobjectivevalue(m))
println("X = ", getvalue(x))
println("X = ", getvalue(y))
