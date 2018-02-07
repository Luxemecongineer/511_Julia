# Sen Lu, Linear Algebra. All examples come from QuantEcon

#--- In Julia, a vector can be represented as a one dimensional Array
x = ones(3)
y = [2,4,6]

z = [2 4 6]
z[2]
z[1,2]
z[2] == z[1,2]
z'

y = ones(2,1)
z = ones(2)
y == z
y[:,1] ==z


x + y
4x

#--- Inner product and Norm
dot(x,y)  # Inner product of x and y
sum(x.*y)  # operator of inner product
norm(x)  # Norm of x
sqrt(sum(x.^2))  # operator of Norm

#--- Span/ Linear combinations/

#---Matrices in Julia
A = [1 2
    3 4]
typeof(A)
A = eye(3)
B = ones(3,3)
2A
A + B
A*B
A.*B

#--- Solving systems of equations
# recall related knowledge of Determinants/ rank/ span/ independence/ linear combination/ root
A = [1.0 2.0;3.0 4.0]
y = ones(2,1)
det(A)
A_inv = inv(A)
x = A_inv*y
z1= A*x
z2= A\y   # Notice that z2 = A^{-1} y = inv(A) y = A \ y

#--- Eigenvectors and Eigenvalues
A = [1.0 2.0;2.0 1.0]
evals, evecs = eig(A)
A * evecs[:,1] - evals[1] * evecs[:,1] #test of the operator
# generalized eignvalues
# eig(A,B)

#--- Other topics
# Series Expansions -> Matrix Norms
# Neumann's theorem
# Spectral Radius
# Positive Definite Matrices
