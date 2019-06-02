using VertexSafeGraphs

using Test
import Random

import LightGraphs
const LG = LightGraphs

@testset "Graph construction and basic interface" begin
    nv = 20
    g1 = VSafeGraph(nv)
    @test LG.nv(g1) == nv
    @test LG.nv(g1.g) == nv

    g2_inner = LG.CompleteGraph(nv)
    g2 = VSafeGraph(g2_inner)
    @test LG.nv(g2) == LG.nv(g2_inner)
    @test LG.ne(g2) == LG.ne(g2_inner)

    @test all(sort(collect(LG.vertices(g2))) .== sort(collect(LG.vertices(g2_inner))))

    g3 = VSafeGraph(LG.CompleteDiGraph(30))
    @test LG.is_directed(g3)
    @test !LG.is_directed(g2)
end

@testset "Vertex deletion" begin
    Random.seed!(33)
    nv = 45
    inner = LG.CompleteGraph(nv)
    g = VSafeGraph(inner)
    @test LG.ne(inner) == LG.ne(g)
    @test LG.nv(inner) == LG.nv(g)
    nrm = 0
    for _ in 1:15
        removed_ok = LG.rem_vertex!(g, rand(1:nv))
        if !removed_ok
            continue
        end
        nrm += 1
        @test LG.nv(inner) == nv
        @test LG.nv(g) == nv - nrm
        @test length(g.deleted_vertices) == nrm

        @test LG.ne(inner) == LG.ne(g)
    end
end

@testset "Edge addition" begin
    Random.seed!(45)
    nv = 10
    inner = CompleteGraph(nv)
    g = VSafeGraph(inner)
    nea = 0         #number of edges added
    nrv = 0         #number of removed vertices
    neo = LG.ne(g)  #original number of edges
    for _ in 1:5
        removed_ok = LG.rem_vertex!(g, rand(1:nv))
        if !removed_ok
            continue
        end
        nrv += 1
    end
    ne = length(edges(g))   #new number of edges
    for _ in 1:10
        v1 = rand(1:nv)
        v2 = rand(1:nv)
        while v2 == v1
            v2 = rand(1:nv)
        end
        added_ok = add_edge!(g, v1, v2)
        if added_ok
            nea += 1
        end
        
        @test LG.ne(inner) == neo
        @test LG.ne(g) == nv + nea
    end
end

@testset "Generic LG algorithms work" begin
    nv = 45
    inner = LG.CompleteGraph(nv)
    g = VSafeGraph(inner)
    removed_ok = LG.rem_vertex!(g, rand(1:nv))
    @test removed_ok
    # LG broken here
    @test_throws BoundsError LG.pagerank(g)
    @test_throws BoundsError LG.kruskal_mst(g)
end
