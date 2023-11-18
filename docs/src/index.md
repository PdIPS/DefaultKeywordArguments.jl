```@meta
CurrentModule = DefaultKeywordArguments
```

# DefaultKeywordArguments.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://PdIPS.github.io/DefaultKeywordArguments.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://PdIPS.github.io/DefaultKeywordArguments.jl/dev/)
[![Build Status](https://github.com/PdIPS/DefaultKeywordArguments.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/PdIPS/DefaultKeywordArguments.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/PdIPS/DefaultKeywordArguments.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/PdIPS/DefaultKeywordArguments.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**DefaultKeywordArguments.jl** is a package to handle *default keyword arguments* in Julia. It has been developed to support [CBX.jl](https://github.com/PdIPS/CBX.jl).

## The `@default` Macro

In Julia, functions can have keyword arguments with a default value. The function
```jl
with_keywords(x; a = 2.0, b = 3.0, c = 4.0) = (a * x + b) / c;
```
will return `(2.0 * x + 3.0) / 4.0` unless you specify a different value of `a`, `b`, or `c`.

When you're writing a complex piece of software, you may have multiple functions that use the keyword arguments `a`, `b`, and `c`, and which should all use the same default value. For instance:
```jl
with_keywords(x; a = 2.0, b = 3.0, c = 4.0) = (a * x + b) / c;
another_with_keywords(x; a = 2.0, b = 3.0, c = 4.0) = round(Int, (a * x + b) / c);
yet_another_with_keywords(x; a = 2.0, b = 3.0, c = 4.0) = round(Int, c / (a * x + b));
```
If you have many functions and many keyword arguments, maintaining consistency of the default values can soon become cumbersome. One sensible option would be to collect all the default values in a single place:
```jl
const default_values = (; a = 2.0, b = 3.0, c = 4.0);
with_keywords(x; a = default_values.a, b = default_values.b, c = default_values.c) = (a * x + b) / c;
another_with_keywords(x; a = default_values.a, b = default_values.b, c = default_values.c) = round(Int, (a * x + b) / c);
yet_another_with_keywords(x; a = default_values.a, b = default_values.b, c = default_values.c) = round(Int, c / (a * x + b));
```
However, writing `a = default_values.a`, `b = default_values.b`, and `c = default_values.c` over and over is tedious, and can clutter your code.

The `@default` macro offers an alternative:
```jl
const default_values = (; a = 2.0, b = 3.0, c = 4.0);
@default default_values with_keywords(x; a, b, c) = (a * x + b) / c;
@default default_values another_with_keywords(x; a, b, c) = round(Int, (a * x + b) / c);
@default default_values yet_another_with_keywords(x; a, b, c) = round(Int, c / (a * x + b));
```
You can write non-compact functions instead:
```jl
const default_values = (; a = 2.0, b = 3.0, c = 4.0);
@default default_values function with_keywords(x::Float64; a, b, c)
  return (a * x + b) / c
end
```
You can also write type annotations and default values as usual. Furthermore, you can overwrite the default values of each keyword argument individually, if required. These are all valid:
```jl
const default_values = (; a = 2.0, b = 3.0, c = 4.0);

# x must be a Float64
@default default_values with_keywords(x::Float64; a, b, c) = (a * x + b) / c;

# x has a default value of 7
@default default_values another_with_keywords(x = 7; a, b, c) = round(Int, (a * x + b) / c);

# the default value of a is overriden to 17.5
@default default_values yet_another_with_keywords(x; a = 17.5, b, c) = round(Int, c / (a * x + b));
```

## The `@config` Macro

You might require a more advanced version of parameter handling, where you just pass a `config` object which propagates across your functions, and then they selectively use default values for certain variables whenever they are not available in `config`:
```jl
function first_call(config)
  a = (haskey(config, :a)) ? config.a : 2.0
  b = (haskey(config, :b)) ? config.b : 3.0
  # some code
  return second_call(config)
end

function second_call(config)
  a = (haskey(config, :a)) ? config.a : 2.0
  c = (haskey(config, :c)) ? config.c : 4.0
  # some more code
end
```
Calling `my_config = (; a = 1.0); first_call(my_config)` would use your custom value of `a` in both functions, but use the default values of `b` and `c` when required.

A way to maintain consistency of the default values would be to replace this with:
```jl
const default_config = (; a = 2.0, b = 3.0, c = 4.0);

function first_call(config)
  return first_call_expanded(config; config...)
end

function first_call_expanded(config; a = default_config.a, b = default_config.b, args...)
  b = (haskey(config, :b)) ? config.b : 3.0
  # some code
  return second_call(config)
end

function second_call(config)
  return second_call_expanded(config; config...)
end

function second_call_expanded(config; a = default_config.a, c = default_config.c, args...)
  # some more code
end
```
This code is verbose and repetitive. However, it can be generated by the `@config` macro instead:
```jl
const default_config = (; a = 2.0, b = 3.0, c = 4.0);

@config default_config function first_call(; a, b)
  # some code
  return second_call(config)
end

@config default_config function second_call(; a, c)
  # some more code
end
```
To avoid repetition, **you don't even have to specify the `config` argument** on each function. Calling `my_config = (; a = 1.0); first_call(my_config)` will behave as in the previous code.

Once again, you are allowed to have extra arguments, type annotations, or default values, as you would in any other Julia function.

:warning: The code pattern generated by `@config` allocates some heap memory. This macro should be used for high-level functions that are not performance-critical.

## Function Documentation

```@index
```

```@autodocs
Modules = [DefaultKeywordArguments]
```