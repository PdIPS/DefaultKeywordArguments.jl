using Test, SafeTestsets

@testset "Default.jl" begin
  for test ∈ ["aqua", "format", "@config", "@default"]
    @eval begin
      @safetestset $test begin
        include($test * ".jl")
      end
    end
  end
end
