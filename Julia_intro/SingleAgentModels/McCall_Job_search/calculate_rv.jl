# Sen Lu

#--- Test 1
include("MJS_Module.jl")
using MJS_module

x = 1.0
y = MJS_module.test_m1(x)
println(y)
pwd()

#--- Test 2
include("C:\\working\\cs\\Econometrics\\511_Julia\\test_module.jl")
using MyTestModule
println(x())
