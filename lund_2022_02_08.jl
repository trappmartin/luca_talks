### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0bc12fe2-4d08-4840-b651-b58df23f0277
using IntervalLinearAlgebra, LazySets, Plots, StaticArrays, PlutoUI

# ╔═╡ f403b050-e2e6-11eb-1c44-911de0d748bd
html"<button onclick='present()'>present</button>"

# ╔═╡ c9e05bd9-1d7b-41c0-99dc-29b1c1e20090
html"""
<style>
.flex-container {
	display : flex;
}

.left {
	float : left;
	
}

.right {
	float : right;
}
</style>
<h1>IntervalLinearAlgebra.jl</h1>
<div class="flex-container">
<div class="left">
<h3>Linear algebra done rigorously</h3>
<p><b>Luca Ferranti</b></p>
<p><i>2022-02-08, Lund</i></p></div>
<div class="right">
<img width=300" src="https://raw.githubusercontent.com/JuliaIntervals/IntervalLinearAlgebra.jl/main/docs/src/assets/logo.svg"></div></div>"""

# ╔═╡ c7627ace-f697-4f5b-bb69-fedd7c45ffa8
md"""
## Background: Interval Arithmetic

- **simple idea**: replace real numbers with intervals
```math
[a, b] = \{x\in\mathbb{R}:a\le x\le b\}
```
- **goals**:
  - Self-validated numerics: allows to do rigorous mathematical proofs with floating point numbers
  - uncertainty propagation

- **Some success stories**:
  - Proof Lorenz attractor is a strange attractor [Smale's 14th problem](https://en.wikipedia.org/wiki/Lorenz_system#Resolution_of_Smale's_14th_problem)
  - Proof of [Kepler conjecture](https://mathworld.wolfram.com/KeplerConjecture.html)

"""

# ╔═╡ 1276b17f-7fe9-40c7-8d81-25efd9b9e6ea
md"""
## The devil in the details
"""

# ╔═╡ 1aebc980-53a2-41c4-89d1-7cb0cdc6df62
a = interval(0.1)

# ╔═╡ 9379f519-bf6b-425f-a386-6a70e2e1ea68
1//10 in a

# ╔═╡ 34615d34-68c4-4b4e-b5af-45f4129b493a
big(0.1)

# ╔═╡ 28360a18-5aa8-45ce-9105-8f5fd3f14847
1//10 ∈ 0.1..0.1

# ╔═╡ 690666f0-95e6-45af-9a43-a219382b54e4
md"""
## The big devil in the details: rounding

- When computing floating point computations, the result is (by default) rounded to the nearest floating point number (could be up or down)
- This is generally handled at hardware level, at software level you lose information of the rounding direction
- For interval computations you need **direct rounding**: round up for upper bound and round down for lower bound.

- For arithmetic operations:
  - Change rounding mode (slow, can cause parallelism issues)
  - Use [error-free transformation](https://www-pequan.lip6.fr/~graillat/papers/nolta07.pdf)
  - Widen the result by one ULP in each direction

- For elementary functions:
  - use correctly rounded functions: [CRLibm](https://github.com/JuliaIntervals/CRlibm.jl), upcoming [CORE-MATH](https://core-math.gitlabpages.inria.fr/)
  - use arbitrary precision arithmetic, e.g. [Arb](https://arblib.org/), [MPFR](https://www.mpfr.org/)
"""

# ╔═╡ fed93a18-7b38-47c6-9966-8ce0f1019103
md"""
## A few examples
- The first is a rigorous proof that the function doesn't have a root over ``[5, 6]``.
- The second is a rigorous proof that the function is monotone over the interval.
"""

# ╔═╡ de38215e-2400-4040-91fd-ff99b1f1c6b9
let
	f(x) = x^2 + x + 1
	f(5..6)
end

# ╔═╡ c8bb489a-4f87-439c-9226-21a9c5db6371
let
	df(x) = 2*x + 1
	df(5..6)
end

# ╔═╡ 0783ae2a-a700-4d4f-bfc0-1e134fca3dca
md"""
## Challenges

- **Dependency problem**: when a variable occures multiple times in an expression, evaluating it with interval arithmetic may lead to overestimation.
"""

# ╔═╡ 3ad42fb7-00b0-4580-a0ab-f958684765c9
let
	x = 1..2
	x - x
end

# ╔═╡ e69f4f04-4775-4a18-bbbe-4ded4faabbcb
let
	f(x) = x^2 -2x
	plot(IntervalBox(-5..5, f(-5..5)), label="enclosure", α=0.5)
	plot!(f, -5, 5, label="f", lw=2)
end

# ╔═╡ 6c0c3973-1d53-43d5-b1e0-fc8c7b27a5cc
md"""
##
in this specific situation we can complete the square ``f(x)=(x-1)^2 + 1``
"""

# ╔═╡ 250da12f-4433-4f9b-b008-34e7dd662453
let
	f(x) = (x - 1)^2 + 1
	plot(IntervalBox(-5..5, f(-5..5)), label="enclosure", α=0.5)
	plot!(f, -5, 5, label="f", lw=2)
end

# ╔═╡ 98799b6e-aa5b-4b37-86db-ebebd9ba67f4
md"""
##
In general, we can mince the interval
"""

# ╔═╡ 0385122b-0b05-4110-9e3f-a28cce581f04
@bind n_intervals Slider(1:20; show_value=true, default=1)

# ╔═╡ f198359e-5f79-455a-97f6-987a2bc98158
let
	f(x) = x^2 - 2x
	X = -5..5
	XX = mince(X, n_intervals)
	fXX = f.(XX)
	plot(IntervalBox.(XX, fXX), label="enclosure", α=0.5)
	plot!(f, -5, 5, label="f", lw=2)
end

# ╔═╡ 888650dd-9a74-4c86-bd65-2dbe7a94100e
md"""
## IntervalArithmetic gotchas!

- Dependency problem
  - mincing
  - [affine arithmetic](https://en.wikipedia.org/wiki/Affine_arithmetic)

- Dimensionality curse
  - [parallel computing](https://www.youtube.com/watch?v=8E0qdO_jRZ0)

- [Clustering effect](https://juliaintervals.github.io/pages/tutorials/tutorialOptimisation/#clustering_problem)
  - mid-value form
"""

# ╔═╡ c3a5fd72-9a9d-45f3-aaf3-bd61637d286c
md"""
## Interval matrices

An interval matrix $\mathbf{A}\in\mathbb{I}\mathbb{R}^{m\times n}$ is defined as

$\mathbf{A} = \{A \in \mathbb{R}^{m\times n} | A_{ij}\in\mathbf{A}_{ij}\quad i=1,\ldots,m\quad j=1\ldots,n\}$

for example
"""

# ╔═╡ f2cff36e-9136-4eb1-acff-c97af31c2450
AA = [1..2 3..4; 5..6 7..8]

# ╔═╡ 286f40a2-840d-431b-a531-fe9e09dc55f1
md"""
##

 $\mathbf{A}$ can also be represented in *midpoint-radius* notation $A_c\pm A_\Delta$, where $A_c$ is the *midpoint matrix* and $A_\Delta$ is the *radius matrix*.
"""

# ╔═╡ 97e498f5-2e0c-4139-9774-86f58d59d511
AA

# ╔═╡ bb878728-d4ca-4c01-a4f7-bf1811a8f5c2
mid.(AA)

# ╔═╡ a89ee6e9-565a-46d5-82db-bafb251a2200
radius.(AA)

# ╔═╡ 4848561e-2336-40fb-a5c6-8705da85c2ee
md"""
##

### Regular matrices
We say that an interval matrix $\mathbf{A}$ is **regular** if all $A\in\mathbf{A}$ are invertible. Otherwise, the interval matrix is **singular**.

- In general, checking for regularity or singularity is computationally expensive.
"""

# ╔═╡ 5b111f71-4d41-43cf-a3cf-e2a6f4c2adba
html"
<table>
  <tr>
    <th>real</th>
    <th>interval</th>
	<th>check property</th>
  </tr>
  <tr>
    <td>invertible</td>
    <td>regular</td>
	<td>coNP-complete</td>
  </tr>
  <tr>
    <td>singular</td>
    <td>singular</td>
	<td>NP-complete</td>
  </tr>
"

# ╔═╡ 395b75e5-e76f-4f3a-b51f-57eaa3de2d4e
md"""
## Interval linear systems

We are now ready to study the square interval linear system $\mathbf{Ax}=\mathbf{b}$ with $\mathbf{A}\in\mathbb{IR}^{n\times n}$ and $\mathbf{b}\in\mathbb{IR}^n$.
"""

# ╔═╡ f39f94f7-59ff-4dd0-93dd-4f9f158c673c
md"""
The solution set $\mathbf{x}$ is defined as

$\mathbf{x}=\{x\in\mathbb{R}^n | Ax=b\text{ for some } A\in\mathbf{A}, b\in\mathbf{b}\}$
"""

# ╔═╡ 3f5a6fed-6175-4459-8be2-9a330cedc938
md"""
- If $\mathbf{A}$ is regular, then the solution set is non-empty and bounded.
"""

# ╔═╡ c223f95a-9885-48ae-b939-4f3fa54a7987
md"""
##
### Finding the solution set

- How do we solve the square interval linear system $\mathbf{A}\mathbf{x}=\mathbf{b}$?
- A naive approach might be to use Monte Carlo, i.e. generate several random real instances from the interval system.
- We will use the following as running example
"""

# ╔═╡ 32f0ff22-d42f-410f-a1a6-b8ea77b696ff
A = [2..4 -2..1;-1..2 2..4]

# ╔═╡ a79e27c9-399c-44e1-ac79-f65480fe5178
b = [-2..2, -2..2]

# ╔═╡ ba3a1ca6-04dc-45db-b686-a036519f2bc9
md"""
##
"""

# ╔═╡ 38883c77-d506-4e81-9d25-0ac78323241a
begin
	Ns = 100_000
	Astatic = @SMatrix [2..4 -2..1;-1..2 2..4]
	bstatic = @SVector [-2..2, -2..2]
	xs = [rand.(A)\rand.(b) for _ in 1:Ns]
	x = [xs[i][1] for i in 1:Ns]
	y = [xs[i][2] for i in 1:Ns]
	histogram2d(x, y, ratio=1)
end

# ╔═╡ 4549ca50-615c-4fba-afde-303ad231f648
md"""
- Pictures obtained by uniformly samplying 100_000 times each interval.
- **Did we cover the whole set?**
"""

# ╔═╡ 0f196850-f4b1-4830-9198-d72a281da05c
md"""
## Solution set characterization

An important theorem, known as **Oettli-Präger theorem**, helps us describing the solution set $\mathbf{x}$.

###### Oettli-Präger theorem
Given the square interval linear system $\mathbf{Ax}=\mathbf{b}$, then

$
x\in\mathbf{x}\Leftrightarrow|A_cx-b_c|\le A_\Delta|x|+b_\Delta$

- The absolute value is taken elementwise.

- We can remove the absolute values by considering one orthant at the time, obtaining $2^n$ systems of linear inequalities.

- Impractical for higher dimensions!
"""



# ╔═╡ d5e3856d-07e7-4e50-9e4d-c0afb7091d8b
md"""
##
"""

# ╔═╡ 95edbbbf-2e35-446d-9eeb-a53f5c6b10ec
polytopes = solve(A, b, LinearOettliPrager());

# ╔═╡ 4880c8a6-de84-4e55-be90-f73256b0888a
begin
	plot(polytopes, ratio=1)
	histogram2d!(x, y)
end

# ╔═╡ 75a66d2a-01b9-4d6a-8fed-8d8159ba6354
md"""
##
### A 3D example
Below the solution of the interval system with

$
\begin{bmatrix}
[4.5, 4.5]&[0, 2]&[0, 2]\\
[0, 2]&[4.5, 4.5]&[0, 2]\\
[0, 2]&[0, 2]& [4.5, 4.5]
\end{bmatrix}\mathbf{x}=\begin{bmatrix}[-1, 1]\\
[-1, 1]\\
[-1, 1]\end{bmatrix}$

"""

# ╔═╡ cd558a80-2825-4953-870c-93551f60c10e
md"""
![](https://raw.githubusercontent.com/lucaferranti/ILAjuliacon2021/main/3dexample.png)
"""

# ╔═╡ c5aa282c-c82b-4521-994d-235cb7934c83
md"""
##
### Exact solution, conclusions
* In general, the solution set of an interval linear system is a non-convex polytope.
  - however it is convex in each orthant.
* The computational complexity to find the solution set grows exponentially with the dimension,
* An alternative more feasible approach is to find a *tight enclosure* of the solution.
"""

# ╔═╡ 32481e35-1a98-4b65-b925-264d51d24743
md"""
## Enclosures of interval linear systems

- We say that an interval box $\mathbf{\Sigma}$ is an enclosure of the set $\mathbf{x}$ if $\mathbf{x}\subseteq\mathbf{\Sigma}$

- Ideally, we want the *hull* of the solution $\mathbf{\Sigma}_{H}$, that is the tightest interval box.

- However, finding the exact hull is in general NP-hard
"""

# ╔═╡ 58b8b1b8-93e7-46c0-b0a0-28532b152908
begin
	plot(interval_hull(ConvexHullArray(polytopes)), label="hull", α=0.3)
	plot!(polytopes, ratio=1, α=1)
end

# ╔═╡ faa03639-a431-4cbf-ac03-bbb33fb7b5b8
md"""
## Algorithms to find the enclosure of the system

`InteralLinearAlgebra.jl` has several algorithms to compute an enclosure of $\mathbf{Ax}=\mathbf{b}$ and an user friendly interface to choose what algorithm and precondition mechanisms to use.

#### Implemented algorithms
- Gaussian elimination
- Gauss-Seidel
- Jacobi
- Hansen-Bliek-Rohn
- Krawczyk
"""

# ╔═╡ 5e0cf15b-21ab-45bb-81fa-ee962a46004f
Xge = solve(A, b, GaussianElimination(), NoPrecondition())

# ╔═╡ fc08d410-02fa-480b-a999-841476dfaaf6
md"""
##
"""

# ╔═╡ 57a5fb2a-5cb2-412f-a1a0-5d27e0a5b8f7
begin
	plot(interval_hull(ConvexHullArray(polytopes)), label="hull", α=0.3)
	plot!(IntervalBox(Xge), label="Gaussian elimination", α=0.2, legend=:right)
	plot!(polytopes, ratio=1, α=1)
end

# ╔═╡ a70a6137-88cf-4fd5-ad50-8d76a1379a27
md"""
- For some special cases, the algorithm will return the hull, but in general some overestimation will occur.
"""

# ╔═╡ 0308378a-2d36-4c47-add7-0f53dc9011ca
md"""
## Preconditioning

- For the previous algorithms to work and be numerically stable, there are some requirements on the matrix $\mathbf{A}$.
- If those requirements are not met, one can try to precondition the problem with a *real* matrix $C$. that is apply the algorithms to the linear system

$
C\mathbf{Ax}=C\mathbf{b}$
- A particularly good choice is $C\approx A_c^{-1}$
"""

# ╔═╡ 9dba04bd-a8c3-44da-a1ab-855829c824ae
md"""
##
To understand the need for preconditioning, let us consider the following example.
"""

# ╔═╡ 8f68a5f0-4ec9-40d5-89be-cddf0c34a977
@bind N Slider(2:100; show_value=true, default=5)

# ╔═╡ 22abccab-5c93-4aa4-90e4-8209997a9a86
A1 = tril(fill(1..1, N, N))

# ╔═╡ e77a478d-0270-4120-a2d4-36efc455fb2e
b1 = [-2..2, fill(0..0, N-1)...]

# ╔═╡ 1ec87e5e-2f90-490b-a94f-05ea53d4cb1d
md"""
The correct solution is $[[-2, 2], [-2, 2], [0, 0], [0, 0], \ldots]$
"""

# ╔═╡ de8734a4-46b8-45ba-aff1-fa6a73e85d96
md"""
##
"""

# ╔═╡ e3bee176-9b9a-448f-b2d0-fa53cad35555
solve(A1, b1, GaussianElimination(), NoPrecondition())

# ╔═╡ 495e13e3-bf20-4541-ab6c-f6cb9572e9ed
solve(A1, b1, HansenBliekRohn(), NoPrecondition())

# ╔═╡ f223ac43-79cd-43be-b585-907a0bfb8f27
md"""
##
"""

# ╔═╡ acb54294-917d-41b0-b501-364b9228531b
solve(A1, b1, GaussianElimination(), InverseMidpoint())

# ╔═╡ ea231b9c-4cc9-4d45-b171-4c66536b02a1
solve(A1, b1, HansenBliekRohn(), InverseMidpoint())

# ╔═╡ 44813e6f-d7a2-47d6-9862-b9fd3e102ee2
md"""
##
### Downsides of preconditioning

- In general, the solution set of the preconditioned problem is **not** the solution set of of the original problem.
- Let us consider our previous 2D example.
"""

# ╔═╡ 1a1b8edf-bc1a-466e-b714-3eb71aa145ce
begin
	polytopes2 = solve(A, b, LinearOettliPrager(), InverseMidpoint())
	plot(UnionSetArray(polytopes2), ratio=1, label="preconditioned", legend=:right)
	plot!(UnionSetArray(polytopes), label="original", α=1) 
end

# ╔═╡ d8735a5e-8444-4724-9796-a59b37efd0e2
md"""
##
### Take-home lesson
- In general preconditioning is needed to achieve numerical stability.
- This may however enlarge the solution set.
- If preconditioning is not specified, the package performs some heuristic checks to decide a precondition strategy.
"""

# ╔═╡ bf3842cd-41f3-4643-abf8-a79ba0b314dd
solve(A1, b1)

# ╔═╡ bd7f0628-81f7-462d-aaaa-cb53ca5b544d
md"""
## Parametric Interval Linear Systems (PILS)

- The above showed theory is nice... but not very useful in practical applications applications
- Because the previous methods assume all intervals are **independent**, whereas in practical applications they depend on a few parameters
- A linear system $$A(p)x=b(p)$$, where the $$A$$ and $$b$$ depend on the vector of parameters $$p$$.
- The values of $$p$$ range in the intervals given in the interval vector $$\hat{\mathbf{p}}$$.
- **Dependency problem kicks in!!**
"""

# ╔═╡ 61d4a271-2893-40b3-8659-1d51f57f1782
md"""
## Simple Application: structural mechanics
![](https://raw.githubusercontent.com/JuliaIntervals/IntervalLinearAlgebra.jl/main/docs/src/assets/trussDiagram.svg)

- compute the displacement of each node.
- Assume there's a 10% uncertainty with the stress of the third element.
"""

# ╔═╡ d4b4a1db-5f70-49ab-9799-e15cc740b54a
begin
	E = 2e11
	σ = 0.005
	s12 = s21 = s34 = s43 = s45 = s54 = E*σ/sqrt(2)
	s13 = s31 = s24 = s42 = s35 = s53 = E*σ/2
end

# ╔═╡ 634f218f-511f-467a-8e11-24c75df25ef9
@affinevars s

# ╔═╡ 9b0bb882-804d-442e-8863-4beb6744cbd9
srange = E*σ/sqrt(2) ± 0.1 * E*σ/sqrt(2)

# ╔═╡ b61cd3ee-cd42-491c-96ac-04e836f6d628
md"""
##
"""

# ╔═╡ 6c7c84db-e289-44e4-a8cb-dd5ca6019fca
K = AffineParametricArray([s12/2+s13 -s12/2 -s12/2 -s13 0 0 0;
     -s21/2 (s21+s)/2+s24 (s21-s)/2 -s/2 s/2 -s24 0;
     -s21/2 (s21-s)/2 (s21+s)/2 s/2 -s/2 0 0;
     -s31 -s/2 s/2 s31+(s+s34)/2+s35 (s34-s)/2 -s34/2 -s34/2;
     0 s/2 -s/2 (s34 - s)/2 (s34+s)/2 -s34/2 -s34/2;
    0 -s42 0 -s43/2 -s43/2 s42+(s43+s45)/2 0;
    0 0 0 -s43/2 -s43/2 0 (s43+s45)/2])

# ╔═╡ f23a2d61-d1ff-46fe-b174-d6a3ce8dcbf3
q = [0, 0, -10.0^4, 0, 0, 0, 0]

# ╔═╡ 35eed775-caef-4f56-a1ad-bfd0728b1922
K(srange)

# ╔═╡ 1c52387c-c377-46e1-a6d2-42a8a4947f1f
md"""
##
"""

# ╔═╡ c73dd757-3bcf-40cd-b95d-b56f998a9071
u = solve(K(srange), interval.(q))

# ╔═╡ 21753483-c8ac-4a92-96b6-2aac72533c56
up = solve(K, q, srange)

# ╔═╡ 6308a7a7-09e7-4fd7-8dfe-203e3ab18849
[u up]/1e-6

# ╔═╡ 26a81fdb-41bc-44c3-916e-d1b031c0e9f0
begin
	nodesCMatrix = [ 0. 0. ;
                 1. 1. ;
                 2. 0. ;
                 3. 1. ;
                 4. 0. ];
# the connectivity matrix is given by
## connectivity  start end
connecMatrix = [ 1     2 ;
                 1     3 ;
                 2     3 ;
                 2     4 ;
                 3     4 ;
                 3     5 ;
                 4     5 ];
# and the fixed degrees of freedom (supports) are defined by the vector
fixedDofs     = [2 9 10 ];
#
# calculations
numNodes = size( nodesCMatrix )[1]; # compute the number of nodes
numElems = size( connecMatrix )[1]; # compute the number of elements
	freeDofs = zeros(Int8, 2*numNodes-length(fixedDofs));
indDof  = 1 ; counter = 0 ;
while indDof <= (2*numNodes)
  if !(indDof in fixedDofs)
    global counter = counter + 1 ;
    freeDofs[ counter ] = indDof ;
  end
  global indDof = indDof + 1 ;
end
	scaleFactor = 100 ;
	UGmin = zeros( 2*numNodes );
	UGmax = zeros(2*numNodes);
	UGminp = zeros(2*numNodes);
	UGmaxp = zeros(2*numNodes);
UGmin[ freeDofs ] = inf.(u) ;
UGmax[freeDofs] = sup.(u);
	UGminp[ freeDofs ] = inf.(up) ;
UGmaxp[freeDofs] = sup.(up);
fig = plot();
fig2 = plot()
for elem in 1:numElems
  indexFirstNode  = connecMatrix[ elem, 1 ];
  indexSecondNode = connecMatrix[ elem, 2 ];
  ## plot reference element
  plot!(fig, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ],
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ],
         linestyle = :dash,  aspect_ratio = :equal,
         linecolor = "black", legend = false)

   plot!(fig2, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ],
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ],
         linestyle = :dash,  aspect_ratio = :equal,
         linecolor = "black", legend = false)
  ## plot deformed element
  plot!(fig, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ]
           + scaleFactor* [ UGmin[indexFirstNode*2-1], UGmin[indexSecondNode*2-1]] ,
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ]
           + scaleFactor* [ UGmin[indexFirstNode*2  ], UGmin[indexSecondNode*2  ]] , markershape = :circle, aspect_ratio = :equal, linecolor = "red",
           linewidth=1.5, legend = false )
	  plot!(fig, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ]
           + scaleFactor* [ UGmax[indexFirstNode*2-1], UGmax[indexSecondNode*2-1]] ,
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ]
           + scaleFactor* [ UGmax[indexFirstNode*2  ], UGmax[indexSecondNode*2  ]] , markershape = :circle, aspect_ratio = :equal, linecolor = "blue",
           linewidth=1.5, legend = false )

	  plot!(fig2, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ]
           + scaleFactor* [ UGminp[indexFirstNode*2-1], UGminp[indexSecondNode*2-1]] ,
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ]
           + scaleFactor* [ UGminp[indexFirstNode*2  ], UGminp[indexSecondNode*2  ]] , markershape = :circle, aspect_ratio = :equal, linecolor = "red",
           linewidth=1.5, legend = false )
	  plot!(fig2, nodesCMatrix[ [indexFirstNode, indexSecondNode], 1 ]
           + scaleFactor* [ UGmaxp[indexFirstNode*2-1], UGmaxp[indexSecondNode*2-1]] ,
         nodesCMatrix[ [indexFirstNode, indexSecondNode], 2 ]
           + scaleFactor* [ UGmaxp[indexFirstNode*2  ], UGmaxp[indexSecondNode*2  ]] , markershape = :circle, aspect_ratio = :equal, linecolor = "blue",
           linewidth=1.5, legend = false )
	xlabel!(fig, "x (m)") # hide
ylabel!(fig, "y (m)") # hide
title!(fig, "Deformed with scale factor " * string(scaleFactor) * " naive approach" ) # hide
		xlabel!(fig2, "x (m)") # hide
ylabel!(fig2, "y (m)") # hide
title!(fig2, "Deformed with scale factor " * string(scaleFactor) * " parametric approach" ) # hide
end
end

# ╔═╡ d319a31a-6b80-456e-b67f-a7828bcdf46c
md"""
##
"""

# ╔═╡ 1f149e74-f51c-4f80-a6b1-bd9ad2e60b75
fig

# ╔═╡ 3fd3bf64-2398-4eda-962c-87f4d9cc25c0
fig2

# ╔═╡ 15a0bbff-9c01-457d-86f8-1614e0031450
md"""
## A continuous mechanics problem
-  ~450 nodes
-  normal non-parametric approaches fail to solve the problem (the matrix is not strongly regular)
- See the full example [here](https://juliaintervals.github.io/IntervalLinearAlgebra.jl/stable/applications/FEM_example/)
"""

# ╔═╡ 9a5ad792-b0c2-4c8b-8f19-fc55ca8b2fdd
md"""
![](https://juliaintervals.github.io/IntervalLinearAlgebra.jl/stable/applications/displacement2.png)
"""

# ╔═╡ e757da5a-675d-4734-a222-7247101aff65
md"""
## Miscellaneous features of the package
- Rump fast matrix multiplication algorithm
![](https://raw.githubusercontent.com/lucaferranti/lucaferranti.github.io/main/posts/2021/08/figures/benchmark.png)
"""

# ╔═╡ 5a8bd918-e9e6-4128-b6b3-335c6cd41651
md"""
- bound eigenvalues of interval matrices
$$\begin{bmatrix}[-3, -2]&[4, 5]&[4, 6]&[-1, 1.5]\\
    [-4, -3]&[-4, -3]&[-4, -3]&[1, 2]\\
    [-5, -4]&[2, 3]&[-5, -4]&[-1, 0]\\
    [-1, 0.1]&[0, 1]&[1, 2]&[-4, 2.5]\end{bmatrix}$$
![](https://raw.githubusercontent.com/lucaferranti/lucaferranti.github.io/main/posts/2021/08/figures/eigenvalues.png)
"""

# ╔═╡ 1e9bf340-2dca-4602-a60c-b2ccdc9cfb85
md"""
## Conclusions

- [IntervalLinearAlgebra.jl](https://github.com/lucaferranti/IntervalLinearAlgebra.jl) offers (will offer) a toolbox to deal with interval linear systems.
- New features (possibly!) coming: 
  - [Parametric interval systems](https://github.com/JuliaIntervals/IntervalLinearAlgebra.jl/issues/99)
  - Determinant computation

- Ultimate goal: **Linear algebra done rigorously!**
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
IntervalLinearAlgebra = "92cbe1ac-9c24-436b-b0c9-5f7317aedcd5"
LazySets = "b4f0291d-fe17-52bc-9479-3d1a343d9043"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
IntervalLinearAlgebra = "~0.1.5"
LazySets = "~1.55.0"
Plots = "~1.25.8"
PlutoUI = "~0.7.34"
StaticArrays = "~1.3.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "940001114a0147b6e4d10624276d56d531dd9b49"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.2"

[[deps.BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "32abd86e3c2025db5172aa182b982debed519834"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.1"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "84083a5136b6abf426174a58325ffd159dd6d94f"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.ErrorfreeArithmetic]]
git-tree-sha1 = "d6863c556f1142a061532e79f611aa46be201686"
uuid = "90fa49ef-747e-5e6f-a989-263ba693cf1a"
version = "0.5.2"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ae13fcbc7ab8f16b0856729b050ef0c446aa3492"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.4+0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FastRounding]]
deps = ["ErrorfreeArithmetic", "Test"]
git-tree-sha1 = "224175e213fd4fe112db3eea05d66b308dc2bf6b"
uuid = "fa42c844-2597-5d31-933b-ebd51ab2693f"
version = "0.2.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "1bd6fc0c344fc0cbee1f42f8d2e7ec8253dda2d2"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.25"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[deps.GLPK]]
deps = ["BinaryProvider", "CEnum", "GLPK_jll", "Libdl", "MathOptInterface"]
git-tree-sha1 = "6f4e9754ee93e2b2ff40c0b0a6b4cdffd289190d"
uuid = "60bf3e95-4087-53dc-ae20-288a0d20c6a6"
version = "0.15.3"

[[deps.GLPK_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "fe68622f32828aa92275895fdb324a85894a5b1b"
uuid = "e8aa6df9-e6ca-548a-97ff-1f85fc5b8b98"
version = "5.0.1+0"

[[deps.GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "FastRounding", "LinearAlgebra", "Markdown", "Random", "RecipesBase", "RoundingEmulator", "SetRounding", "StaticArrays"]
git-tree-sha1 = "bbf2793a70c0a7aaa09aa298b277fe1b90e06d78"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.20.3"

[[deps.IntervalLinearAlgebra]]
deps = ["CommonSolve", "IntervalArithmetic", "LinearAlgebra", "Reexport", "Requires", "StaticArrays"]
git-tree-sha1 = "a9027448e81d9c35f5f787a5cfb6b50b31038698"
uuid = "92cbe1ac-9c24-436b-b0c9-5f7317aedcd5"
version = "0.1.5"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuMP]]
deps = ["Calculus", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MathOptInterface", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "Random", "SparseArrays", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "30bbc998df62c12eee113685c6f4d2ad30a8781c"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "0.22.2"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[deps.LazySets]]
deps = ["Distributed", "ExprTools", "GLPK", "InteractiveUtils", "IntervalArithmetic", "JuMP", "LinearAlgebra", "Random", "RecipesBase", "Reexport", "Requires", "SharedArrays", "SparseArrays"]
git-tree-sha1 = "e92e22dcd8abf31f9418213936aa41399740dd94"
uuid = "b4f0291d-fe17-52bc-9479-3d1a343d9043"
version = "1.55.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "JSON", "LinearAlgebra", "MutableArithmetics", "OrderedCollections", "Printf", "SparseArrays", "Test", "Unicode"]
git-tree-sha1 = "625f78c57a263e943f525d3860f30e4d200124ab"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "0.10.8"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "73deac2cbae0820f43971fad6c08f6c4f2784ff2"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.3.2"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "eb1432ec2b781f70ce2126c277d120554605669a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.8"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8979e9802b4ac3d58c503a20f2824ad67f9074dd"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.34"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SetRounding]]
git-tree-sha1 = "d7a25e439d07a17b7cdf97eecee504c50fedf5f6"
uuid = "3cc68bcd-71a2-5612-b932-767ffbe40ab0"
version = "0.2.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "8d0c8e3d0ff211d9ff4a0c2307d876c99d10bdf1"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a635a9333989a094bddc9f940c04c549cd66afcf"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─f403b050-e2e6-11eb-1c44-911de0d748bd
# ╠═0bc12fe2-4d08-4840-b651-b58df23f0277
# ╟─c9e05bd9-1d7b-41c0-99dc-29b1c1e20090
# ╟─c7627ace-f697-4f5b-bb69-fedd7c45ffa8
# ╟─1276b17f-7fe9-40c7-8d81-25efd9b9e6ea
# ╠═1aebc980-53a2-41c4-89d1-7cb0cdc6df62
# ╠═9379f519-bf6b-425f-a386-6a70e2e1ea68
# ╠═34615d34-68c4-4b4e-b5af-45f4129b493a
# ╠═28360a18-5aa8-45ce-9105-8f5fd3f14847
# ╟─690666f0-95e6-45af-9a43-a219382b54e4
# ╟─fed93a18-7b38-47c6-9966-8ce0f1019103
# ╠═de38215e-2400-4040-91fd-ff99b1f1c6b9
# ╠═c8bb489a-4f87-439c-9226-21a9c5db6371
# ╟─0783ae2a-a700-4d4f-bfc0-1e134fca3dca
# ╠═3ad42fb7-00b0-4580-a0ab-f958684765c9
# ╠═e69f4f04-4775-4a18-bbbe-4ded4faabbcb
# ╟─6c0c3973-1d53-43d5-b1e0-fc8c7b27a5cc
# ╠═250da12f-4433-4f9b-b008-34e7dd662453
# ╟─98799b6e-aa5b-4b37-86db-ebebd9ba67f4
# ╠═0385122b-0b05-4110-9e3f-a28cce581f04
# ╟─f198359e-5f79-455a-97f6-987a2bc98158
# ╟─888650dd-9a74-4c86-bd65-2dbe7a94100e
# ╟─c3a5fd72-9a9d-45f3-aaf3-bd61637d286c
# ╟─f2cff36e-9136-4eb1-acff-c97af31c2450
# ╟─286f40a2-840d-431b-a531-fe9e09dc55f1
# ╟─97e498f5-2e0c-4139-9774-86f58d59d511
# ╠═bb878728-d4ca-4c01-a4f7-bf1811a8f5c2
# ╠═a89ee6e9-565a-46d5-82db-bafb251a2200
# ╟─4848561e-2336-40fb-a5c6-8705da85c2ee
# ╟─5b111f71-4d41-43cf-a3cf-e2a6f4c2adba
# ╟─395b75e5-e76f-4f3a-b51f-57eaa3de2d4e
# ╟─f39f94f7-59ff-4dd0-93dd-4f9f158c673c
# ╟─3f5a6fed-6175-4459-8be2-9a330cedc938
# ╟─c223f95a-9885-48ae-b939-4f3fa54a7987
# ╠═32f0ff22-d42f-410f-a1a6-b8ea77b696ff
# ╠═a79e27c9-399c-44e1-ac79-f65480fe5178
# ╟─ba3a1ca6-04dc-45db-b686-a036519f2bc9
# ╟─38883c77-d506-4e81-9d25-0ac78323241a
# ╟─4549ca50-615c-4fba-afde-303ad231f648
# ╟─0f196850-f4b1-4830-9198-d72a281da05c
# ╟─d5e3856d-07e7-4e50-9e4d-c0afb7091d8b
# ╠═95edbbbf-2e35-446d-9eeb-a53f5c6b10ec
# ╟─4880c8a6-de84-4e55-be90-f73256b0888a
# ╟─75a66d2a-01b9-4d6a-8fed-8d8159ba6354
# ╟─cd558a80-2825-4953-870c-93551f60c10e
# ╟─c5aa282c-c82b-4521-994d-235cb7934c83
# ╟─32481e35-1a98-4b65-b925-264d51d24743
# ╟─58b8b1b8-93e7-46c0-b0a0-28532b152908
# ╟─faa03639-a431-4cbf-ac03-bbb33fb7b5b8
# ╠═5e0cf15b-21ab-45bb-81fa-ee962a46004f
# ╟─fc08d410-02fa-480b-a999-841476dfaaf6
# ╟─57a5fb2a-5cb2-412f-a1a0-5d27e0a5b8f7
# ╟─a70a6137-88cf-4fd5-ad50-8d76a1379a27
# ╟─0308378a-2d36-4c47-add7-0f53dc9011ca
# ╟─9dba04bd-a8c3-44da-a1ab-855829c824ae
# ╟─8f68a5f0-4ec9-40d5-89be-cddf0c34a977
# ╟─22abccab-5c93-4aa4-90e4-8209997a9a86
# ╟─e77a478d-0270-4120-a2d4-36efc455fb2e
# ╟─1ec87e5e-2f90-490b-a94f-05ea53d4cb1d
# ╟─de8734a4-46b8-45ba-aff1-fa6a73e85d96
# ╠═e3bee176-9b9a-448f-b2d0-fa53cad35555
# ╠═495e13e3-bf20-4541-ab6c-f6cb9572e9ed
# ╟─f223ac43-79cd-43be-b585-907a0bfb8f27
# ╠═acb54294-917d-41b0-b501-364b9228531b
# ╠═ea231b9c-4cc9-4d45-b171-4c66536b02a1
# ╟─44813e6f-d7a2-47d6-9862-b9fd3e102ee2
# ╟─1a1b8edf-bc1a-466e-b714-3eb71aa145ce
# ╟─d8735a5e-8444-4724-9796-a59b37efd0e2
# ╠═bf3842cd-41f3-4643-abf8-a79ba0b314dd
# ╟─bd7f0628-81f7-462d-aaaa-cb53ca5b544d
# ╟─61d4a271-2893-40b3-8659-1d51f57f1782
# ╠═d4b4a1db-5f70-49ab-9799-e15cc740b54a
# ╠═634f218f-511f-467a-8e11-24c75df25ef9
# ╠═9b0bb882-804d-442e-8863-4beb6744cbd9
# ╟─b61cd3ee-cd42-491c-96ac-04e836f6d628
# ╠═6c7c84db-e289-44e4-a8cb-dd5ca6019fca
# ╠═f23a2d61-d1ff-46fe-b174-d6a3ce8dcbf3
# ╠═35eed775-caef-4f56-a1ad-bfd0728b1922
# ╟─1c52387c-c377-46e1-a6d2-42a8a4947f1f
# ╠═c73dd757-3bcf-40cd-b95d-b56f998a9071
# ╠═21753483-c8ac-4a92-96b6-2aac72533c56
# ╠═6308a7a7-09e7-4fd7-8dfe-203e3ab18849
# ╟─26a81fdb-41bc-44c3-916e-d1b031c0e9f0
# ╟─d319a31a-6b80-456e-b67f-a7828bcdf46c
# ╟─1f149e74-f51c-4f80-a6b1-bd9ad2e60b75
# ╟─3fd3bf64-2398-4eda-962c-87f4d9cc25c0
# ╟─15a0bbff-9c01-457d-86f8-1614e0031450
# ╟─9a5ad792-b0c2-4c8b-8f19-fc55ca8b2fdd
# ╟─e757da5a-675d-4734-a222-7247101aff65
# ╟─5a8bd918-e9e6-4128-b6b3-335c6cd41651
# ╟─1e9bf340-2dca-4602-a60c-b2ccdc9cfb85
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
