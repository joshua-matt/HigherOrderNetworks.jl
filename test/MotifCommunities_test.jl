using Test
include("MotifCommunities.jl")
include("Utilities.jl")

karate_edges = [[2,1],[3,1],[3,2],[4,1],[4,2],[4,3],[5,1],[6,1],[7,1],[7,5],[7,6],[8,1],[8,2],[8,3],[8,4],[9,1],
[9,3],[10,3],[11,1],[11,5],[1,6],[12,1],[13,1],[13,4],[14,1],[14,2],[14,3],[14,4],[17,6],[17,7],[18,1],[18,2],
[20,1],[20,2],[22,1],[22,2],[26,24],[26,25],[28,3],[28,24],[28,25],[29,3],[30,24],[30,27],[31,2],[31,9],[32,1],
[32,25],[32,26],[32,29],[33,3],[33,9],[33,15],[33,16],[33,19],[33,21],[33,23],[33,24],[33,30],[33,31],[33,32],[34,9],
[34,10],[34,14],[34,15],[34,16],[34,19],[34,20],[34,21],[34,23],[34,24],[34,27],[34,28],[34,29],[34,30],[34,31],[34,32],[34,33]]
karate_edges = reduce(vcat, [[i, reverse(i)] for i in karate_edges])
K = MatrixNetwork(map(x->x[1],karate_edges),map(x->x[2],karate_edges)) # Zachary's Karate Club

A = MatrixNetwork([1,1,2,2,3,3,3,4,4,4,5,5,5,6,6,7,7,8,8,8,9,9,10,10],
                  [2,3,1,3,1,2,4,3,5,8,4,6,7,5,7,5,6,4,9,10,8,10,8,9])

@testset "Modularity" begin
    mod(A::MatrixNetwork,
        C::Vector{Vector{Int64}};
        M::MatrixNetwork=MatrixNetwork([1],[2])) = motif_modularity(A,C;M=M)[1]

    @test mod(A, [[i for i = 1:10]]) == 0.
    @test mod(A, [[1,2,3,4], [5,6,7], [8,9,10]]) == 0.48958333333333337
    @test mod(A, [[1,2,3,4], [5,6,7], [8,9,10]]) ==
          mod(A, [[1,2,3], [4,5,6,7], [8,9,10]]) ==
          mod(A, [[1,2,3], [5,6,7], [4,8,9,10]])
    @test mod(A, [[1,2,3,4], [5,6,7], [8,9,10]]; M=clique(3)) == 0.8624989471979267
    @test mod(K, [[1,2,3,4,5,6,7,8,9,11,12,13,14,17,18,20,22],
                  [10,15,16,19,21,23,24,25,26,27,28,29,30,31,32,33,34]]) == 0.3568055321302074
    @test mod(K, [[1,2,3,4,5,6,7,8,9,11,12,13,14,17,18,20,22],
                  [10,15,16,19,21,23,24,25,26,27,28,29,30,31,32,33,34]]; M=path(2)) == 0.4814330690954068
end

@testset "Community Detection" begin
    @test_throws AssertionError louvain_motif(MatrixNetwork(Vector{Tuple{Int64,Int64}}(), 0)) == []
    @test louvain_motif(MatrixNetwork(Vector{Tuple{Int64,Int64}}(), 1)) == [[1]]
    @test louvain_motif(A) == [[1,2,3], [4,8,9,10], [5,6,7]]
    @test louvain_motif(A; M=clique(3)) == [[1,2,3], [4], [5,6,7], [8,9,10]]
    @test louvain_motif(K; M=path(2)) == [[1,2,3,4,5,6,7,8,9,11,12,13,14,17,18,20,22],
                                          [10,15,16,19,21,23,24,25,26,27,28,29,30,31,32,33,34]]

    D = MatrixNetwork([(1,2),(1,3),(1,4),(2,3),(2,4),(3,5),(3,10),(5,6),(5,8),(6,7),(6,8),(6,9),
                       (7,9),(8,9),(8,12),(9,11),(10,11),(10,13),(10,14),(11,12),(11,13),(12,14),(13,14)], 14)
    D = make_undirected(D)
    @test louvain_motif(D) == [[1,2,3,4],[5,6,7,8,9],[10,11,12,13,14]]
    @test louvain_motif(D; M=clique(3)) == [[1,2,3,4],[5,6,7,8,9],[10,11,13,14],[12]]
end
