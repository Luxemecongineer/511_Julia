function f(b)
    return 2.0 + b
end


function geta(a)
    for i =1:100
        a += a+ f(a)
    end
    return a
end

a = geta(1)
println(a)

@time geta(1)
