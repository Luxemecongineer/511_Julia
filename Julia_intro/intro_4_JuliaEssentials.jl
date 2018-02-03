# Sen Lu, examples from quantecon.org.
# Chp Julia Essentials. All examples from QuantEcon. 

#--- Primitive Data Types
x = true
typeof(x)
y = 1>2
println(y)
z = true + false
println(z)
sum([true, false, true, false, true])

typeof(1.0)
typeof(1)
x = 2; y=1.0
println(x*y)
+(10,20)
*(10,20)
#--- Strings
x = "foobar"
typeof(x)
x= 10; y=20
"x = $x"
z = x+y
println("x + y =$z")
"foo" * "bar"
s = "Charlie don't surf"
split(s)
replace(s, "surf", "ski")
split("fee,fi,fo", ",")
strip("  foobar  ")
#--- Julia can also find and replace using regular expressions
match(r"(\d+)","Top 10")

#--- Containers
# For tuples, which act as "immutable" arrays
x = ("foo","bar")
typeof(x)
#immutable like you run: x[1]=42
word1, word2 = x
#--- Referencing Items
x = [10, 20, 30, 40]
x[end]
x[end-1]
x[1:3]
x[2:end]
# slice could also work on strings
"foobar"[3:end]

#--- DICTIONARIES which is quite important when deal with json data file
d = Dict("name"=>("Frodo","Sen","Kevin"),"age"=>(33,32,44))
d["age"]
# println(d)
typeof(d["age"])
println(keys(d))
println(values(d))

#--- Reading from and writing to text files
f = open("newfile.txt","w") # "w" is for writing
write(f, "testing\n") # \n for newline
write(f, "More testing \n")
close(f) # this line create the file with contents

f = open("newfile.txt", "r")
contents = readstring(f)
close(f)
println(contents)

#--- test appdend
f = open("newfile.txt","w") # "w" is for writing
write(f, "next testing\n") # \n for newline
write(f, "is that ok \n")
close(f) # this line create the file with contents
#---  try append!
f = open("newfile.txt","a") # "w" is for writing
write(f, "testing\n") # \n for newline
write(f, "More testing \n")
close(f) # this line create the file with contents

#--- Iterables: run interation through Julia
# sequence data types like arrays
actions = ["surf", "ski"]
for word in actions
    println("Charlie don't $word")
end

for i in 1:3
    print(i)
end

#--- Looping without Indices
# Loop over sequences without explicit indexing, which often leads to neater code
x_values = linspace(0,3,10)
for x in x_values
    println(x*x)
end

for i in 1:length(x_values)
    println(x_values[i]*x_values[i])
end

#--- Julia also provides some functional-style helper functons to facilitate looping without indices
# one example is zip()
countries = ("Japan", "Korea", "China")
cities = ("Tokyo","Seoul","Beijing")
for (country, city) in zip(countries, cities)
    println("The capital city of $country is $city")
end

zip_var = zip(countries, cities)
println(zip_var)
typeof(zip_var)

# use another method, say enumerate()
countries =("Japan","Korea","China")
cities = ("Tokyo","Seoul","Beijing")
for (i, city) in enumerate(cities)
    country = countries[i]
    println("The capital of $country is $city")
end

# Comprehensions are tool for creating new arrays or dictionaries from iterables
doubles = [2i for i in 1:4]

animals = ["dog", "cat", "bird"];
plurals = [animal * "s" for animal in animals]
[i + j for i in 1:3, j in 4:6]
[i + j + k for i in 1:3, j in 4:6, k in 7:9]
Dict("$i" => i for i in 1:3)

#--- Comparisons and Logical Operators
x = 1
x ==2
x != 3
1<2<3
1<=2<=3
# In julia one couldn't use integers or other values when testing conditions but Julia is more fussy
# like run: while 0 println("foo") end
# like run: if 1 print ("foo") end
true && false
true||false

#--- User-defined Functions
function f1(a,b)
    return a*b
end

function foo(x)
    if x>0
        return "Positive"
    end
    return "Negative"
end
foo(5)

# Other syntax for defining functions
# it is neater, as it doesn't require function keyword or end
ff(x) = sin(1/x)
ff(1/pi)
# Map
map(x-> sin(1/x), randn(3))
#--- Function arguments can be given default values
function fff(x; a=1)
    return exp(cos(a*x))
end
println(fff(pi))
println(fff(pi,2))
println(fff(pi, a=3))

#--- Vectorized Functions
#  apply a function f to every element of a vector x_vec to produce a new vector y_vec
# x_vec = [2.0, 4.0, 6.0, 8.0]
x_vec = [2.0*i for i in 1:4]
y_vec = similar(x_vec)
for (i,x) in enumerate(x_vec)
    y_vec[i] = sin(x)
end
println(y_vec)
# Julia offers another alternative syntax
z_vec = sin.(x_vec)
# In Julia, if f is any Julia function, then f. references the vectorized version
# ###### set assert in a function!!!! ########
function chisq(k::Integer)
    @assert k>0 "K must b e a natural number"
    z = randn(k)
    y = sum(z.^2)
    return y
end
chisq(3)
# chisq(-2)
chisq.([2,3,4,5])

#--- Exercises
#--- Exercise 1
#Part 1
x_vals = randn(3)
y_vals = similar(x_vals)
for (i,x) in enumerate(x_vals)
    y_vals[i] = x^2
end

out_v = 0
for (x, y) in zip(x_vals, y_vals)
    out_v += x*y
end
println(out_v)
#Part 2
count_mtx = [x%2 for x in 0:99]
typeof(count_mtx)
# numb_even = 100-sum(count_mtx)

sum([x%2==0 for x in 0:99])

#--- Exercise 3
n = 8
a = randn(n)
x = pi
function p_ex2(x,a)
    value = 0
    # k = length(a)
    for (i,y) in enumerate(a)
        value += y*(x^i)
    end
    return value
end
println(p_ex2(x, a))
#--- Exercise
function f_ex3(string)
    count = 0
    for letter in string
        if (letter == uppercase(letter)) && isalpha(letter)
            count += 1
        end
    end
    return count
end

f_ex3("Tmr we have MicroEconomics Theory taught by Hulya")

#--- Exercise 4
function f_ex4(seq_a, seq_b)
    is_subset = true
    for a in seq_a
        if !(a in seq_b)
            is_subset = false
        end
    end
    return is_subset
end
#== test ==#
println(f_ex4([1,2],[1,2,3,4]))
println(f_ex4([1,2,5],[1,2,3,4]))
#--- Exercise 5
function linapprox(f, a, b, n, x)
    #=
    Evaluates the piecewise linear interpolant of f at x on the interval
    [a, b], with n evenly spaced grid points.

    =#
    length_of_interval = b - a
    num_subintervals = n - 1
    step = length_of_interval / num_subintervals

    # === find first grid point larger than x === #
    point = a
    while point <= x
        point += step
    end

    # === x must lie between the gridpoints (point - step) and point === #
    u, v = point - step, point

    return f(u) + (x - u) * (f(v) - f(u)) / (v - u)
end

#== test
f_ex5(x) = x^2
g_ex5(x) = linapprox(f_ex5, -1, 1, 3, x)
using Plots
pyplot()
x_grid = linspace(-1, 1, 100)
y_vals = map(f_ex5, x_grid)
y_approx = map(g_ex5, x_grid)
plot(x_grid, y_vals, label="true")
plot!(x_grid, y_approx, label="approximation")
gui()
==#
