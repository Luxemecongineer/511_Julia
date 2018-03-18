using Distributions
using Plots
pyplot()

ndim = 2
nsamples =10000

mu = zeros(ndim)
sig = eye(ndim) * 0.8

fDist = MvNormal(mu, 2*sig)
gDist = MvNormal(mu,sig)

samplesFromG = rand(gDist, nsamples)
f(x) = pdf(fDist,x)
g(x) = pdf(gDist,x)

sum(f(samplesFromG)./g(samplesFromG))/nsamples
z = f(samplesFromG)./g(samplesFromG)

function likelihoodFunction(theta::Array{Float64,2},sigF::Array{Float64,2})
    ndim = size(theta,1)
    ndata = size(theta,2)
    mu =[ mean(theta[i,:]) for i in 1:ndim ]
    likelihood = (2*pi)^(-ndim/2) * det(sigF)^(-0.5) *
    exp(-*(*(theta-mu,inv(sigF)),transpose(theta-mu) ))
    return likelihood
end
gui()
