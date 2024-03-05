using DefaultKeywordArguments, JuliaFormatter, Test

function tests()
  f(s) = format(s; DefaultKeywordArguments.FORMAT_SETTINGS...)
  f("..")
  @test f("..")
end

tests()
