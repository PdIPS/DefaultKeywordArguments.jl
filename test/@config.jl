using DefaultKeywordArguments, Test

const default_config = (; a = 1, b = 1.0, c = 1 // 1)

function tests()
  config = (; a = 2, b = 3.0, c = 5 // 1)
  config2 = (; d = 2)
  config3 = (; a = 1.0)

  @config no_args() = 1.0
  @test no_args(config) == 1.0

  @config no_defaults(x) = x
  @test no_defaults(config, 0.0) == 0

  @config default_config with_defaults(x) = x
  @test with_defaults(config, 0.0) == 0

  @config default_config with_type(x::Float64) = x
  @test with_type(config, 0.0) == 0
  @test_throws MethodError with_type(config, 0)

  @config default_config with_optional_arg(x::Float64 = 1.0) = x
  @test with_optional_arg(config, 0.0) == 0
  @test with_optional_arg(config) == 1

  @config default_config with_one_par(x; a) = a * x
  @test with_one_par(config, 1.0) == 2 * 1
  @test with_one_par(config, 2.0) == 2 * 2
  @test with_one_par(config2, 1.0) == 1 * 1
  @test with_one_par(config2, 2.0) == 1 * 2

  @config with_missing_par(x; a) = a * x
  @test_throws Exception with_missing_par(config2, 1.0)

  @config default_config with_two_pars(x; a, b) = a * x + b * x^2
  @test with_two_pars(config, 1.0) == 2 * 1 + 3 * 1^2
  @test with_two_pars(config, 2.0) == 2 * 2 + 3 * 2^2
  @test with_two_pars(config2, 1.0) == 1 * 1 + 1 * 1^2
  @test with_two_pars(config2, 2.0) == 1 * 2 + 1 * 2^2

  @config default_config with_par_type(x; a::Int) = a * x
  @test with_par_type(config, 1.0) == 2 * 1
  @test with_par_type(config, 2.0) == 2 * 2
  @test_throws TypeError with_par_type(config3, 1.0)

  @config default_config with_par_default(x; a, b = 7) = a * x + b * x^2
  @test with_par_default(config, 1.0) == 2 * 1 + 3 * 1^2
  @test with_par_default(config2, 1.0) == 1 * 1 + 7 * 1^2
end

tests()
