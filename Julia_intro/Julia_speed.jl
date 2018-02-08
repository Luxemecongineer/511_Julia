# Sen Lu, examples in the script comes from QuantEcon

# Compare the speed of using global variables
#--- Excution 1
b =1.0
function g(a)
    for i in 1:1_000_000
        tmp = a + b
    end
end

@time g(1.0)
#--- Excution 2
function h(a,b)
    for i in 1:1_000_000
        tmp = a+b
    end
end

@time h(1.0, 1.0)
println(h(1.0,1.0))
#--- Excution 3  prepend the global variable with const
const b_const = 1.0
function k(a)
    for i in 1:1_000_000
        tmp = a + b_const
    end
end
@time k(1.0)

#--- composite types with abstract field types
struct Foo_generic
    a
end

struct Foo_abstract
    a::Real
end

struct Foo_concrete{T <: Real}  # Actually this is parametrically typed case
    a::T
end

fg = Foo_generic(1.0)
fa = Foo_abstract(1.0)
fc = Foo_concrete(1.0)
typeof(fc)

#  Test the timing
function f(foo)
    for i in 1:1_000_000
        tmp = i + foo.a
    end
end

@time f(fg)
@time f(fa)
@time f(fc)
# one more execution gets speed up
