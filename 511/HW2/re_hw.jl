# Sen Lu. Econometrics HW2
# Julia v6.0

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

# Drop null rows. THIS IS DISTURBING. Julia allow nullable array type!
null_column = []
for i in 1:length(df[:motheduc])
    if !isnull(df[:motheduc][i])
        nothing
    else
        push!(null_column,i)
    end
end

# Delete multiple rows. args should be Vector of Int.
deleterows!(df, Int.(null_column))


R1_df = DataFrame(smk = Vector(dropnull(df[:smoke])),
medu = Vector(dropnull(df[:motheduc])),
white = Vector(dropnull(df[:white])),
inc = Vector(dropnull(df[:lfaminc]))),
Probit = glm(@formula(smk~ medu + white + inc), R1_df, Binomial(),ProbitLink())

Probit
