# TidyTable

[![Build Status](https://github.com/kdpsingh/TidyTable.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/TidyTable.jl/actions/workflows/CI.yml?query=branch%3Amain)

Welcome to the TidyTable.jl project. This is a project that wraps the {tidytable} package in R, which provides {tidyverse} bindings to the lightning-fast {data.table package}. Unlike other DataFrames packages and meta-packages in Julia, this package allows you to provide syntax exactly as you would write it in tidyverse.

More docs are coming soon.

## Install and load the package and generate a test DataFrame

```julia
import Pkg
Pkg.add(url = "https://github.com/kdpsingh/TidyTable.jl")

using TidyTable
using DataFrames
using Chain
using Statistics

df = DataFrame(a = repeat(1:2, inner = 5), b = 11:20)
```
## Using DataFrames.jl

```julia
@chain df begin
  groupby(:a)
  combine(:b => mean => :b)
end
```

2×2 DataFrame
 Row │ a      b       
     │ Int64  Float64 
─────┼────────────────
   1 │     1     13.0
   2 │     2     18.0

## Using TidyTable.jl

```julia
@chain tidytable(df) begin
  @group_by(a)
  @summarize(b = mean(b))
  as_data_frame()
end
```

2×2 DataFrame
 Row │ a      b       
     │ Int64  Float64 
─────┼────────────────
   1 │     1     13.0
   2 │     2     18.0