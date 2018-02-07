using PyCall
@pyimport numpy.random as nr
z = nr.rand(3,4)
println(z)
