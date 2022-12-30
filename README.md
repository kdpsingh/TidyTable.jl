# TidyTable.jl

[![Build Status](https://github.com/kdpsingh/TidyTable.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/TidyTable.jl/actions/workflows/CI.yml?query=branch%3Amain)

Welcome to the TidyTable.jl project. This is a project that wraps the {tidytable} package in R, which provides {tidyverse} bindings to the lightning-fast {data.table} package. Unlike other DataFrames packages and meta-packages in Julia, this package allows you to provide syntax exactly as you would write it in tidyverse.

More docs are coming soon.

## Install and load the package and generate a test DataFrame

```julia
import Pkg
Pkg.add(url = "https://github.com/kdpsingh/TidyTable.jl")

using TidyTable
using DataFrames
using Chain
using Statistics
using RDatasets

movies = dataset("ggplot2", "movies")
```
## Using DataFrames.jl

```julia
@chain movies begin
  subset(:Year => (x -> x .>= 2000))
  groupby(:Year)
  combine(:Budget => (x -> mean(skipmissing(x))) => :Budget)
  transform(:Budget => (x -> x/1e6) => :Budget)
end
```

```
6×2 DataFrame
 Row │ Year   Budget  
     │ Int32  Float64 
─────┼────────────────
   1 │  2000  23.9477
   2 │  2001  19.2356
   3 │  2002  19.3971
   4 │  2003  15.8683
   5 │  2004  13.9057
   6 │  2005  16.4682
```

## Using TidyTable.jl

```julia
@chain tidytable(movies) begin
  @filter(Year >= 2000)
  @group_by(Year)
  @summarize(Budget = mean(Budget, na.rm = TRUE))
  @mutate(Budget = Budget/1e6)
  collect()
end
```

```
6×2 DataFrame
 Row │ Year   Budget  
     │ Int64  Float64 
─────┼────────────────
   1 │  2000  23.9477
   2 │  2001  19.2356
   3 │  2002  19.3971
   4 │  2003  15.8683
   5 │  2004  13.9057
   6 │  2005  16.4682
```

## Which one is faster?

Both were benchmarked with @time, with Julia running on 6 threads on a Windows virtual machine.

### DataFrames.jl

1st run: 5.966837 seconds (11.12 M allocations: 612.987 MiB, 3.36% gc time, 99.71% compilation time: 36% of which was recompilation)

2nd run: 0.294697 seconds (691.36 k allocations: 36.597 MiB, 97.98% compilation time)

3rd run: 0.289215 seconds (680.42 k allocations: 35.998 MiB, 97.94% compilation time)

### TidyTable.jl

1st run: 5.009644 seconds (3.07 M allocations: 161.663 MiB, 1.23% gc time, 30.50% compilation time: 32% of which was recompilation)

2nd run: 0.050233 seconds (118.08 k allocations: 5.400 MiB)

3rd run: 0.050572 seconds (118.08 k allocations: 5.400 MiB)