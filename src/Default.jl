module Default

macro default(values, method)
  check_is_function_expression(method)
  method_with_defaults = construct_method_with_defaults(values, method)
  return esc(quote
    $method_with_defaults
  end)
end

macro default(method)
  return esc(quote
    @default NamedTuple() $(method)
  end)
end

macro config(values, method)
  check_is_function_expression(method)
  method_with_config_and_defaults =
    construct_method_with_config_and_defaults(values, method)
  method_with_splat = construct_method_with_splat(method)
  return esc(quote
    $method_with_splat
    $method_with_config_and_defaults
  end)
end

macro config(method)
  return esc(quote
    @config NamedTuple() $(method)
  end)
end

function check_is_function_expression(a)
  if !is_function_expression(a)
    throw(
      ArgumentError(
        "@default and @config macros should only be used on a function.",
      ),
    )
  end
  return nothing
end

is_function_expression(a) =
  hasproperty(a, :head) && (a.head == :function || a.head == :(=))

function construct_method_with_defaults(values, method)
  call = method.args[1]
  parameters = (length(call.args) > 1) ? call.args[2] : nothing
  if parameters isa Expr && parameters.head == :parameters
    new_parameters = Expr(
      :parameters,
      map(s -> assign_kw_arg(values, s), parameters.args)...,
      :(args...),
    )
    new_call =
      Expr(call.head, call.args[1], new_parameters, call.args[3:end]...)
  else
    new_parameters = Expr(:parameters, :(args...))
    new_call =
      Expr(call.head, call.args[1], new_parameters, call.args[2:end]...)
  end
  new_method = Expr(method.head, new_call, method.args[2])
  return new_method
end

function assign_kw_arg(values, arg)
  if (arg isa Expr) && (arg.head == :kw)
    return arg
  end
  key = (arg isa Symbol) ? arg : arg.args[1]
  val = Expr(:., values, QuoteNode(key))
  return Expr(:kw, arg, val)
end

function construct_method_with_config_and_defaults(values, method)
  call = method.args[1]
  new_name = Symbol(call.args[1], :_expanded)
  new_arg = Expr(:(::), :config, :NamedTuple)
  parameters = (length(call.args) > 1) ? call.args[2] : nothing
  if parameters isa Expr && parameters.head == :parameters
    new_call =
      Expr(call.head, new_name, parameters, new_arg, call.args[3:end]...)
  else
    new_call = Expr(call.head, new_name, new_arg, call.args[2:end]...)
  end
  new_method = Expr(method.head, new_call, method.args[2])
  return construct_method_with_defaults(values, new_method)
end

function construct_method_with_splat(method)
  call = method.args[1]
  parameters = (length(call.args) > 1) ? call.args[2] : nothing
  if parameters isa Expr && parameters.head == :parameters
    new_args = call.args[3:end]
  else
    new_args = call.args[2:end]
  end
  new_name = Symbol(call.args[1], :_expanded)
  new_arg = Expr(:(::), :config, :NamedTuple)
  new_call = Expr(call.head, call.args[1], new_arg, new_args...)
  body = method.args[2]
  line = body.args[1]
  new_line = (line isa LineNumberNode) ? line : nothing
  new_body = Expr(
    :block,
    new_line,
    Expr(
      :call,
      new_name,
      Expr(:parameters, :(config...)),
      :config,
      map(s -> strip_arg(s), new_args)...,
    ),
  )
  new_method = Expr(:function, new_call, new_body)
  return new_method
end

strip_arg(arg::Symbol) = arg

strip_arg(arg::Expr) = strip_arg(arg.args[1])

export @default, @config

end
