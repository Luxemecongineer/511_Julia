using CUDAdrv
using CUDAnative

function execute(kernel, threads, args...)
    global thread
    for thread in 1:threads
        kernel(args...)
    end
end

function kernel(a,b,c)
    c[thread] = a[thread] + b[thread]
    return
end

a1 = [1,2,3]
b1 = [4,5,6]
c = similar(a1)

execute(kernel,length(a1),a1,b1,c)

a1 + b1 == c

bar() = nothing
Base.@elapsed @cuda (1,1) bar()
#@kernell_benchmark test the time of execution
