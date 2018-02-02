# documents of juliaplots see http://docs.juliaplots.org/latest/tutorial/
#--- test1
using Plots
x = 1:10; y = rand(10); # These are the plotting data
plot(x,y)

x = 1:10; y = rand(10,2) # 2 columns means two lines
plot(x,y)
z = rand(10)
plot!(x,z)

x = 1:10; y = rand(10,2) # 2 columns means two lines
plot(x,y,title="Two Lines",label=["Line 1" "Line 2"],lw=3)
xlabel!("My x label")

#--- Test2
using PyPlot
x = linspace(0, 10, 200)
y = sin.(x)
fig, ax = subplots()
ax[:plot](x, y, "b-", linewidth=2)
