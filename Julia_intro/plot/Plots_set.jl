#--- Plot 0
using Plots
pyplot()
# plot(Plots.fakedata(50,5),w=3)
plot(Plots.fakedata(50,5),w=1.5)  # w = ? specifie linewidth
gui()

#--- Plot 1
using Plots
pyplot()  #choose backend
x = 1:10; y =rand(10);
plot(x,y)
gui()  # gui() always locates at the end!

#--- Plot 2
using Plots
pyplot()
x = 1:10; y=rand(10,2)
plot(x,y)
gui()

#--- Plot 3
using Plots
pyplot()
x = 1:10; y = rand(10,2)
p = plot(x,y)
z = rand(10)
plot!(p,x,z)  # one could directly add more objects at the end of codes.
gui()

#--- Plot 4
using Plots
pyplot()  #choose backend
x = 1:10; y = rand(length(x),2)
plot(x,y,title="Two Lines", label=["Line 1" "Line 2"], lw=2, linestyle=:dashdot)
gui()

#--- Plot 5
using Plots
pyplot()  #choose backend
x = 1:10; y = rand(length(x),2)
# One could pass different styles to different lines.
plot(x,y[:,1],title="Two Lines", label="Line 1", lw=2, linestyle=:dashdot)
# by adding one more line
plot!(x,y[:,2],title="Two Lines", label="Line 2", lw=2, linestyle=:solid)
gui()
#--- Plot 6
# Plot function pairs (x,f(x))
using Plots
pyplot()
plot(sin, (x->begin
                sin(2x)
end),0,2π,line=4,leg=false,fill=(0,:orange))
gui()

#--- Plot 7
using Plots
pyplot()
y = rand(100)
x = 0:10:100
plot(x, rand(11,4), lab=["lines 1" "lines 2" "lines 3" "lines 4"],w=2, palette=:grays,fill = 0, α=0.4)
scatter!(y,zcolor=abs(y-0.5),
                m=(:heat,0.8,stroke(1,:green)),ms=10*abs(y-0.5)+4,lab="grad")
gui()


#--- Plot 8
# This plot is some example about how to add lines, v or h, and how to plot multiple lines
# and pass attributes to them.
# Notice that one could using args to pass xaxis/title/xlabel etc.
# Another alternative method is call shorthand functions.
using Plots
pyplot()
y =rand(20,3)
plot(y,xaxis=("XLABEL",(-5,30),0:2:20,:flip),background_color=RGB(0.2,0.2,0.2),leg=false)
hline!(mean(y,1)+rand(1,3)/10,line=(2,:dash,0.6,[:lightgreen :green :darkgreen]))
vline!([5,10],w=2,linestyle=:dashdot)
title!("Title")
yaxis!("YLABEL",:log10)
gui()

#--- Plot 9
#using Vectors to plot multiple series with different length.
using Plots
pyplot()
ys = Vector[rand(10), rand(20)]
plot(ys, color =[:black :orange], line=(:dot, 4), marker=([:hex :d],12,0.8,stroke(3,:gray)))
gui()
#--- Plot 10
# Build plot in pieces
using Plots
pyplot()
plot(rand(100)/3, lab="trend",reg=true, fill=(0,:green))
scatter!(rand(100),lab="Scatter", markersize=6, c=:orange)
gui()
#--- Plot 11
#Histogram 2D
using Plots
pyplot()
histogram2d(randn(10000),randn(10000),nbins=50)
gui()

#--- Plot 12
# Line styles
# using Plots
# pyplot()
# styles = (filter((s->begin
#             s in Plots.supported_styles()
#         end),[:solid,:dash,:dot,:dashdot,:dashdotdot]))
# n = length(styles)
# y = cumsum(randn(20,n),1)
# plot(y,line=(5,styles),label=map(string,styles))
# gui()


#--- Plot 13
using Plots
pyplot()
ts_length = 100
epsilon_values = randn(ts_length)

typeof(epsilon_values)
println(epsilon_values)

# plot(epsilon_values, fmt= :png)
plot(epsilon_values)
gui()

#--- Plot 14
#--- Plot 15
#--- Plot 16
#--- Plot 17
#--- Plot 18
#--- Plot 19
#--- Plot 20
