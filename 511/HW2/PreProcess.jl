# Sen Lu. Econometrics HW2

# Import modules
using CSV
using DataFrames
using DataFramesMeta
using GLM
using NullableArrays

# Import CSV data file
csv_path = "C:\\working\\cs\\Econometrics\\511_Julia\\511\\HW2\\bwght_csv.csv"
df = CSV.read(csv_path)

# A function that is used to generate smoke binary var.
function gen_smk(x)
    if x>0
        return 1
    else
        return 0
    end
end


df[:smoke] = Vector(gen_smk.(df[:cigs]))


null_column = []
for i in 1:length(df[:motheduc])
    if !isnull(df[:motheduc][i])
        nothing
    else
        push!(null_column,i)
    end
end

for r in null_column
    deleterows!(df, r)
end


R1_df = DataFrame(smk = Vector(dropnull(df[:smoke])), medu = Vector(dropnull(df[:motheduc])), white = Vector(dropnull(df[:white])), inc = Vector(dropnull(df[:lfaminc])))
Probit = glm(@formula(smk~ medu + white + inc), R1_df, Binomial(),ProbitLink())

#--- Second regression

# Import modules
using CSV
using DataFrames
using DataFramesMeta
using GLM
using NullableArrays

# Import CSV data file
csv_path = "C:\\working\\cs\\Econometrics\\511_Julia\\511\\HW2\\bwght_csv.csv"

df2 = CSV.read(csv_path)

# A function that is used to generate smoke binary var.
function gen_smk(x)
    if x>0
        return 1
    else
        return 0
    end
end

df2[:smoke] = Vector(gen_smk.(df2[:cigs]))

null_column_2 = []
for i in 1:length(df2[:motheduc])
    if !isnull(df2[:motheduc][i])&&!isnull(df2[:fatheduc][i])
        nothing
    else
        push!(null_column_2,i)
    end
end

deleterows!(df2,Int.(null_column_2))

R2_df = DataFrame(smk = Vector(dropnull(df2[:smoke])), medu = Vector(dropnull(df2[:motheduc])), white = Vector(dropnull(df2[:white])), inc = Vector(dropnull(df2[:lfaminc])), fedu = Vector(dropnull(df2[:fatheduc])))
OLS = glm(@formula(inc ~ medu + white + fedu), R2_df, Normal(), IdentityLink())

#
# col_medu = df[:motheduc]
#
# dropnull(df[:motheduc])
# isnull.(df[:motheduc])
# dropnull(isnull.(df[:motheduc]))
# describe(df[:motheduc])
# describe(isnull.(df[:motheduc]))
#
# dropnull(df[,:])
#
# df[isnull.(df[:motheduc]),:]
#
#
#
#
#
# R1_df = dropnull(df[:motheduc])
#
#
# col_medu = df[:motheduc]
# col_cigs = df[:cigs]
# col_white = df[:white]
# col_inc = df[:lfaminc]
# col_fedu = df[:fatheduc]
# col_smk = df[:smoke]
#
# R1_df = DataFrame(smk = col_smk, medu = col_medu, white = col_white, inc=col_inc)
#
#
# col_medu[1]
#
# df1 = @select df :motheduc :cigs :white :lfaminc
#
# float(col_medu[1])
#
# dropnull(df[:motheduc])
# isnull.(df[:motheduc])
# dropnull(isnull.(df[:motheduc]))
#
#
#
#
# df[:motheduc]
#
# z = [true, false, true]
# a = [2, 3, 4]
# a[z]
#
#
# #
# # col_cigs =
# #
# #
# # # Add one more column that stores value of smoke var.
# #
# #
# # describe(df_bwght)
# #
# # df = copy(df_bwght)
# # dropnull(df[:motheduc])
# #
# # df[:fatheduc]
# # test = convert.(Array, df[:fatheduc])
# #
# # df[3,:fatheduc]
# # df[~isna(df[:,:fatheduc]),:]
# #
# # # df_bwght[:medu] = float.(Vector(df_bwght[:motheduc]))
# #
# # # descriptive statistics.
# #
# # # df_bwght[:smoke]
# # # df_bwght[:cigs]
# #
# # Probit = glm(@formula(smoke~motheduc), df_bwght, Binomial(),ProbitLink())
# #
# # # df_bwght[df_bwght[:mothedu].==NA]
# #
# # # df_bwght[:fatheduc]
# #
# # df = df_bwght[1:5,:]
# # df[2:3,:smoke] =1
# # df[:smoke]
# # df[:lfaminc]
# # df[:inc] = float.(Vector(df[:lfaminc]))
# # df[:inc]
# # Probit = glm(@formula(smoke~inc), df, Binomial(),ProbitLink())
