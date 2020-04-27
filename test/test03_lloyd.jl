module TestLloyd

using ParallelKMeans
using Test
using Random
using StatsBase

@testset "basic kmeans" begin
    X = [1. 2. 4.;]
    res = kmeans(X, 1; n_threads = 1, tol = 1e-6, verbose = false)
    @test res.assignments == [1, 1, 1]
    @test res.centers[1] ≈ 2.3333333333333335
    @test res.totalcost ≈ 4.666666666666666
    @test res.converged

    res = kmeans(X, 2; n_threads = 1, init = [1.0 4.0], tol = 1e-6, verbose = false)
    @test res.assignments == [1, 1, 2]
    @test res.centers ≈ [1.5 4.0]
    @test res.totalcost ≈ 0.5
    @test res.converged
end

@testset "no convergence yield last result" begin
    X = [1. 2. 4.;]
    res = kmeans(X, 2; n_threads = 1, init = [1.0 4.0], tol = 1e-6, max_iters = 1, verbose = false)
    @test !res.converged
    @test res.totalcost ≈ 0.5
end

@testset "singlethread linear separation" begin
    Random.seed!(2020)

    X = rand(3, 100)
    res = kmeans(X, 3; n_threads = 1, tol = 1e-6, verbose = false)

    @test res.totalcost ≈ 14.16198704459199
    @test res.converged
    @test res.iterations == 11
end

@testset "multithread linear separation quasi two threads" begin
    Random.seed!(2020)

    X = rand(3, 100)
    res = kmeans(X, 3; n_threads = 2, tol = 1e-6, verbose = false)

    @test res.totalcost ≈ 14.16198704459199
    @test res.converged
end

@testset "Lloyd Float32 support" begin
    Random.seed!(2020)

    X = Float32.(rand(3, 100))
    res = kmeans(Lloyd(), X, 3; n_threads = 1, tol = 1e-6, verbose = false)

    @test typeof(res.totalcost) == Float32
    @test res.totalcost ≈ 14.161985f0
    @test res.converged
    @test res.iterations == 11

    Random.seed!(2020)

    X = Float32.(rand(3, 100))
    res = kmeans(Lloyd(), X, 3; n_threads = 2, tol = 1e-6, verbose = false)

    @test typeof(res.totalcost) == Float32
    @test res.totalcost ≈ 14.161985f0
    @test res.converged
    @test res.iterations == 11
end

@testset "Lloyd test weighted X" begin
    Random.seed!(2020)
    X = rand(3, 100)
    weights = rand(100)

    init = sample(1:100, 10, replace = false)
    init = X[:, init]

    res = kmeans(Lloyd(), X, 10, weights; init = init, n_threads = 1, tol = 1e-10, max_iters = 100, verbose = false)
    @test res.totalcost ≈ 2.726538026486045
    @test res.converged
    @test res.iterations == 9

    Random.seed!(2020)
    X = rand(3, 100)
    weights = rand(100)

    res = kmeans(Lloyd(), X, 10, weights; n_threads = 1, tol = 1e-10, max_iters = 100, verbose = false)
    @test res.totalcost ≈ 2.75774704578635
    @test res.converged
    @test res.iterations == 9

    Random.seed!(2020)
    X = rand(3, 100)
    weights = rand(100)

    res = kmeans(Lloyd(), X, 10, weights; n_threads = 1, tol = 1e-10, max_iters = 100, verbose = false)
    @test res.totalcost ≈ 2.75774704578635
    @test res.converged
    @test res.iterations == 9
end

end # module