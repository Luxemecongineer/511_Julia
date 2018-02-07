# Sen Lu, Feb 5. from http://www.stochasticlifestyle.com/7-julia-gotchas-handle/
# try to aviod create new array in inner loop.

# example 1 :: which create a new array each time run inner loop
println("Array Allocation")
function f()
  x = [1;5;6]
  for i = 1:1000000
    x = x + inner1(x)
  end
  return x
end
function inner1(x)
  return 2x
end

@time f()

println("Allocation Free method 1")
function g()
  x = [1;5;6]
  y = Vector{Int64}(3)
  for i = 1:1000000
    inner!(y,x)
    for i in 1:3
      x[i] = x[i] + y[i]
    end
    copy!(y,x)
  end
  return x
end
function inner!(y,x)
  for i=1:3
    y[i] = 2*x[i]
  end
  nothing
end
@time g()

println("Allocation Free method 2")
function k()
  x = [1;3;5]
  y = Vector{Int64}(3)
  for i =1:1000000
    x .= x .+ inner.(x)
  end
  return x
end
function inner(x)
  return 2x
end
@time k()
