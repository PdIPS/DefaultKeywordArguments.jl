using Test, SafeTestsets

@testset "Default.jl" begin
  for test ∈ ["@config", "@default", "aqua", "format"]
    @eval begin
      @safetestset $test begin
        include($test * ".jl")
      end
    end
  end
end
