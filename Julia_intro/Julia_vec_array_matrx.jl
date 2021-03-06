# Sen Lu. All examples comes from QuantEcon
# Jan-31

println("test")

#--- Array
a = [10,20,30]
a = ["foo", "bar", 10]
repr(a)
# In atom, it is Vector{Float64}, while in REPL it says Array{Float64, 1}. They are the same
typeof(randn(100))
# Size function, in Atom, it is (3) [Actually still defined as a tuple], while in REPL it is (3,)
size(a)
typeof(size(a))
ndims(a)

b = eye(3)
c = diagm([2,4])
size(b)

# Array vs Vector vs Matrix
# However, these are just aliases for one-diemensional or two-ddimensional arrays respectively
Array{Int64, 1} == Vector{Int64}
Array{Int64, 2} == Matrix{Int64}

#--- Changing dimensions. The primary function for changing the dimensions of arryas is reshape()
a = [10,20,30]
push!(a,40)
println(a)
b = reshape(a, 2,2)
println(b)
# Notice that reshape function create a view of old one, and therefor they would share modification
b[1,1] = 100
println(a)
#  Use squeeze to modify the dimension of arrays return a flattened array
# Flat Arrays in Julia: 1 Vector   2 two dimensional but nx1 or 1xn
a = [1 2 3 4]
b = [1,2,3,4]
squeeze(a,1)
# c = diagm([2,4])
# squeeze(c,1)

#--- Function that return useful arrays
eye(2)
zeros(3)
x = Array{Float64}(2,2)
ones(2,2)
y = fill("foo",2,2)
z = similar(y)
z[1,1]="Yes"
println(z)

#--- Array indexing
# Create two vector a and b
a = collect(10:10:40)
b = [10*i for i in 1:4]
a == b
c = randn(2, 2)
# Get the first row(column) of arrays c, just like MatlaB
c[1,:]
#--- One very useful method is using booleans to extract elements of an array
a = randn(2,2)
# generate an array of booleans
b = eye(2)
c = Array{Bool}(2,2)
for i in 1:2
    for j in 1:2
        if b[i,j]==1
            c[i,j]=true
        else
            c[i,j]=false
        end
    end
end
println(c)
# using booleans to extract element returns a vector.
d = a[c]
typeof(d)

#--- In julia, one could use slice to set values to multiple elements
a = randn(4)
a[2:end] = 42
println(a)
#--- Passing Arrays: Just as in Python, all arrays are passed by reference, and therefore share modification
# If one want a copy, just use function copy()
a = ones(3)
b = copy(a)
b[3] = 4
println("Test copy() ",b,a," Test over")

# Arrays Methods, standard funtions that for acting on arrays
a = [-1,0,2]
length(a)
sum(a)
mean(a)
median(a)
std(a)
var(a)
maximum(a)
minimum(a)
# sort just return a new array, original not modified. Notice the difference between this with sort!
b = sort(a, rev=true)
b === a
b == a
c = sort!(a, rev=true)
c === a
a

#--- Matrix Algebra
a = ones(1,2)
b = ones(2,2)
α = a * b
β = b*a'

A = [1 2; 2 3]
B = ones(2,2)
# Notice, numerically the first one is more stable. One should keep use first one
println(A\B) # This method is primary choice!
println(inv(A)*B)
# Inner product
dot(ones(2), ones(2))

#--- Elementwise Operations
# multiplication and element-by-element multiplication
# Recall .f() just call funtion elementwise
ones(2,2)*ones(2,2)
ones(2,2).*ones(2,2)
A = -ones(2,2)
A.^2
# Some operators do induce ambiguity, thus for these operators one could omit point.
ones(2,2)+2*ones(2,2)
ones(2,2)+2ones(2,2)

#--- Elementwise comparasions
a = [10,20,30]
b = [100,-10,40]
b.>a
b.<a
a.==b
b.>20
#--- recall the example of using booleans to extract elements
a = randn(4)
b = a.>0
c = a[b]

#--- Vectorized functions
#  Julia provides standard mathematical functions such as log exp sin, etc.
log(1.0)
log.(ones(4))  # Notice that function that act elementwise on arrays in this manner are vectorized functions
[log(x) for x in ones(4)]  # This return same result as previous one

#---Linear Algebra
A = [1 2; 3 4]
θ = det(A)
γ = trace(A)
α = eigvals(A)
β = rank(A)
