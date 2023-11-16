push!(LOAD_PATH, "../src/")

using Default
using Documenter

DocMeta.setdocmeta!(Default, :DocTestSetup, :(using Default); recursive = true)

makedocs(;
  modules = [Default],
  authors = "Dr Rafael Bailo",
  repo = "https://github.com/PdIPS/Default.jl/blob/{commit}{path}#{line}",
  sitename = "Default.jl",
  format = Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://PdIPS.github.io/Default.jl",
    edit_link = "main",
    assets = String[],
  ),
  pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/PdIPS/Default.jl", devbranch = "main")
