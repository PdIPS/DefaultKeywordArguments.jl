using Test, SafeTestsets

@testset "DefaultKeywordArguments.jl" begin
  for test ∈ ["@config", "@default", "aqua", "format"]
    @eval begin
      @safetestset $test begin
        include($test * ".jl")
      end
    end
  end
end
