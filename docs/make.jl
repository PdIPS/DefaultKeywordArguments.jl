push!(LOAD_PATH, "../src/")

using DefaultKeywordArguments
using Documenter

DocMeta.setdocmeta!(
  DefaultKeywordArguments,
  :DocTestSetup,
  :(using DefaultKeywordArguments);
  recursive = true,
)

makedocs(;
  modules = [DefaultKeywordArguments],
  authors = "Dr Rafael Bailo",
  repo = "https://github.com/PdIPS/DefaultKeywordArguments.jl/blob/{commit}{path}#{line}",
  sitename = "DefaultKeywordArguments.jl",
  format = Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://PdIPS.github.io/DefaultKeywordArguments.jl",
    edit_link = "main",
    assets = String[],
    footer = "Copyright © 2023 [Dr Rafael Bailo](https://rafaelbailo.com/). [MIT License](https://github.com/PdIPS/DefaultKeywordArguments.jl/blob/main/LICENSE).",
  ),
  pages = ["Home" => "index.md"],
)

deploydocs(;
  repo = "github.com/PdIPS/DefaultKeywordArguments.jl",
  devbranch = "main",
)
