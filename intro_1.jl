using CSV
using DataFrames
using GLM
using GR

# csv_path = "C:\\working\\cs\\Econometrics\\511_Julia\\data_file.csv"
# df_bwght = CSV.read(csv_path)

# df = DataFrame(A = rand(10),B=rand(10))
#
# function gen_1(x)
#     if x>0.5
#         return 1
#     else
#         return 0
#     end
# end
#
# df[:C] = gen_1.(df[:A])

data = DataFrame(X=[1,2,3], Y=[1,0,1])
data[:X]
Probit = glm(@formula(Y ~ X), data, Binomial(), ProbitLink())

pwd()
