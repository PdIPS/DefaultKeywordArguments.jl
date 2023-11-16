using Default, Test

const default_values = (; a=1, b=1.0, c=1 // 1)

function tests()
  @default no_args() = 1.0
  @test no_args() == 1.0

  @default no_defaults(x) = x
  @test no_defaults(0.0) == 0

  @default default_values with_defaults(x) = x
  @test with_defaults(0.0) == 0

  @default default_values with_type(x::Float64) = x
  @test with_type(0.0) == 0
  @test_throws MethodError with_type(0)

  @default default_values with_optional_arg(x::Float64=1.0) = x
  @test with_optional_arg(0.0) == 0
  @test with_optional_arg() == 1

  @default default_values with_one_par(x; a) = a * x
  @test with_one_par(1.0) == 1 * 1
  @test with_one_par(1.0; a=3) == 3 * 1
  @test with_one_par(2.0) == 1 * 2
  @test with_one_par(2.0; a=3) == 3 * 2

  @default with_missing_par(x; a) = a * x
  @test_throws Exception with_missing_par(1.0)

  @default default_values with_two_pars(x; a, b) = a * x + b * x^2
  @test with_two_pars(1.0) == 1 * 1 + 1 * 1^2
  @test with_two_pars(1.0; a=3) == 3 * 1 + 1 * 1^2
  @test with_two_pars(1.0; b=5) == 1 * 1 + 5 * 1^2
  @test with_two_pars(2.0) == 1 * 2 + 1 * 2^2
  @test with_two_pars(2.0; a=3) == 3 * 2 + 1 * 2^2
  @test with_two_pars(2.0; b=5) == 1 * 2 + 5 * 2^2

  @default default_values with_par_type(x; a::Int) = a * x
  @test with_par_type(1.0) == 1 * 1
  @test with_par_type(1.0; a=3) == 3 * 1
  @test with_par_type(2.0) == 1 * 2
  @test with_par_type(2.0; a=3) == 3 * 2
  @test_throws TypeError with_par_type(1.0; a=3.0)

  @default default_values with_par_default(x; a, b=2) = a * x + b * x^2
  @test with_par_default(1.0) == 1 * 1 + 2 * 1^2
  @test with_par_default(1.0; a=3) == 3 * 1 + 2 * 1^2
  @test with_par_default(1.0; b=5) == 1 * 1 + 5 * 1^2
  @test with_par_default(2.0) == 1 * 2 + 2 * 2^2
  @test with_par_default(2.0; a=3) == 3 * 2 + 2 * 2^2
  @test with_par_default(2.0; b=5) == 1 * 2 + 5 * 2^2
end

tests()
