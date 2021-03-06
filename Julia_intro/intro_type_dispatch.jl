# Sen Lu, examples here comes from QuantEcon
#--- Common Types
typeof(0.5)
typeof(5)
typeof("foo")
typeof('c')
typeof('d')
typeof(1+1im)
typeof(eye(2))

#--- Multiple Dispatch
# Julia inspects the type of data to be acted on and hands it out to the appropriate method

# Example: +( , )
+(1,1)
x,y = 1.0, 1.0
@which +(x,y)
x,y =1,1
@which +(x,y)
x,y = 1.0+1.0im, 1.0+1.0im
@which +(x,y)
# Example: isless
isless(1.0,2.0)
@which isless(1.0,2.0)
@which isless(1,2)

# Example: isfinite()
@which isfinite(1)
@which isfinite(1.0)
methods(isfinite)

#--- Adding Methods
# It's straightforward to add methods to existing functions
# Just like :: +(100,"100")
importall Base.Operators
+(x::Integer, y::String) = x + parse(Int, y)
+(100, "100")
100 + "100"

#--- One could also exploit multiple dispatch in User-defined functions

function h(a::Float64)
    println("You have called the method for handling Float64s wrt $a")
end

function h(a::Int64)
    println("You have called the method for handling Int64 wrt $a")
end

h(0.5)
h(0)

#--- The type Hierarchy
# Type and subtypes
Float64 <: Real
Int64 <: Real
Complex64 <: Real
Complex64 <: Number
Number <: Any

# Back to multiple dispatch
function f(x)
    println("Generic function invoked")
end
function f(x::Number)
    println("Number method invoked")
end
function f(x::Integer)
    println("Integer method invoked")
end
println(f(3),f(3.0),f("foo"))

#--- User-Defined Types
struct Foo
end

foo = Foo()
typeof(foo)

foofunc(x::Foo) = "onefoo"
foofunc(foo)
+(x::Foo, y::Foo) = "twowords"
foo1, foo2 = Foo(), Foo()
+(foo1, foo2)

# One example
mutable struct AR1
    a
    b
    sigma
    phi
end

using Distributions
m = AR1(0.9, 1, 1, Beta(5,5))

# In this call to the constructor we’ve created an instance of AR1 and bound the name m to it
println(m.a,m.b,m.sigma,m.phi)
typeof(m.phi)
typeof(m.phi)<:Distribution
# Modify data while the object is live in memory -- see below
m.phi = Exponential(0.5)
# Then one could figure out the data in container changed.
m

#--- In this type of question, one could also explicitly define our data type
# In the following example, "mutable" is removed, and therefore one couldn't changes the elements of AR1_explicit
struct AR1_explicit  # Define a constructor
    a::Float64
    b::Float64
    sigma::Float64
    phi::Distribution
end
#  Then one can't assign string value to sigma.
# Like assign tuple of value to a instance m : m = AR1_explicit(0.9, 1, "foo", Beta(5, 5))

struct AR1_real # Whereas using abstract types adversely affects performance
    a::Real
    b::Real
    sigma::Real
    phi::Distribution
end

#--- Type Parameters
typeof([10,20,30])
struct AR1_best{T <: Real}
    a::T
    b::T
    sigma::T
    phi::Distribution
end
m = AR1_best(0.9,1.0,1.0, Beta(5,5))


#--- Exercise
using Distributions
# struct simulate
#     m::AR1_best
#     n::Integer
#     x0::Real
# end

struct AR1_ex1{T <: Real}
    a::T
    b::T
    sigma::T
    phi::Distribution
end

# write the function to simulate
function simulate_ex1(m::AR1_ex1, n::Integer, x0::Real)
    X = Array{Float64}(n)
    X[1] = x0
    for t in 1:(n-1)
        X[t+1] = m.a * X[t] + m.b + m.sigma * rand(m.phi)
    end
    return X
end

m = AR1_ex1(0.9,1.0,1.0,Normal(0,1))
X = simulate_ex1(m,100,0.0)
using Plots
plot(X, legend=:none)
