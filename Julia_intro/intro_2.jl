# Sen Lu
#--- calculate the t-stat
t_stat = (0.24+0.94-1)/((0.02277+0.05768-2*0.03433)^0.5);
println("t-stat is equal to $t_stat")
c_value = 1.96
r_result = (t_stat>c_value)
println("Rejction rule yield: $r_result")

#
