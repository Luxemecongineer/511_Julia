# Sen Lu. All related examples come from QuantEcon

#--- Distributions
using Distributions
d1 = Normal()
d1 = Normal(0.0,1.5)
typeof(d1)
d2 = Uniform()
d2 = Uniform(1.0,2.0)
d3 = Binomial()
d3 = Binomial(10,0.4)

# Oneway to draw from a well defined distribution
c1 = rand(d3)  # draw one
c2 = rand(d3, 5)  #draw multiple values
typeof(c2)

# evaluations of this distribution
e1 = mean(d3)  # To obtain the mean of the distribution
e2 = pdf(d3, 3) # the probability density function

#--- DataFrames
using DataFrames
commodities = ["crude", "gas", "silver","gold"]
# @time commodities

# Then create Data array
last_price = @data([4.2,11.3,12.1,NA])
# size(last_price)

# Compile a data frame
df = DataFrame(commod=commodities, price = last_price)
println(df)
# Columns of DataFrame can be accessed by name
df[:price]
df[:price][1]
typeof(df[:price])
df[:commod]
df[:commod][1]
# Dataframe provides a number of methods for acting on Dataframes
# Describe the fundamental statistic description, than run on DataFrame
describe(df)
# write the table to csv files!
writetable("data_file.csv", df)

#--- Interpolation
# In economics, one often wish to interpolate discrete data.
# The package one turn to is Interpolations.jl
# Another alternative, if using univariate Linear interpolation, is LinInterp from QuantEcon.jl

using Interpolations
using Plots
pyplot()

x = -7:7
typeof(x)
y = sin.(x)
xf = -7:0.1:7
typeof(xf)
plot(xf, sin.(xf), label = "sine function")
gui()

#--- another
using QuantEcon
using Plots
pyplot()
x = -7:7
y = sin.(x)
xf = -7:0.1:7

li = LinInterp(x, y)        # create LinInterp object
li(0.3)                     # evaluate at a single point
y_linear_qe = li.(xf)       # evaluate at multiple points

plot(xf, y_linear_qe, label="linear")
gui()
# scatter!(x, y, label="sampled data", markersize=4)
