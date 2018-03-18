# Sen Lu. First try of CUDA in Julia
# Give up. Waiting for officially release of V0.7.....
using CUDAdrv
using CUDAnative

function kernel_vadd(a, b, c)
    # from CUDAnative: (implicit) CuDeviceArray type,
    #                  and thread/block intrinsics
    i = (blockIdx().x-1) * blockDim().x + threadIdx().x
    c[i] = a[i] + b[i]

    return nothing
end

dev = CuDevice(0)
ctx = CuContext(dev)

# generate some data
len = 512
a = rand(Int, len)
b = rand(Int, len)

# allocate & upload on the GPU
d_a = CuArray(a)
d_b = CuArray(b)
d_c = similar(d_a)

# execute and fetch results
@cuda (1,len) kernel_vadd(d_a, d_b, d_c)    # from CUDAnative.jl
c = Array(d_c)

using Base.Test
@test c == a + b

destroy(ctx)
