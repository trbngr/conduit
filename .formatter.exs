# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:cqrs_tools, :ecto, :ecto_sql, :commanded, :commanded_ecto_projections, :phoenix],
  line_length: 120,
  locals_without_parens: [
    router: 1
  ]
]
