module TidyTable

export tidytable, as_data_frame, @select, @filter, @mutate, @summarize, @group_by, @rename, @transmute

macro_symbols = :select, :filter, :mutate, :summarize, :group_by, :rename, :transmute

# for f in macro_symbols
#    @eval begin
#        macro $f(pre, exprs...)
#            quote
#               tup = $(string(exprs))
#               pipe_wrap($(esc(pre)), string($f), tup)
#            end
#        end
#    end
# end

using DataFrames
using RCall
R"""
list.of.packages <- c("tidytable")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages) > 0) install.packages(new.packages)

library(tidytable)
"""

function tidytable(df::DataFrame)
    @rput df
    "df"
end

function as_data_frame(str::AbstractString)
    df = convert(DataFrame,reval(str))
    reval("rm(df)")
    df
end

macro select(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "select", tup)
    end
end

macro filter(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "filter", tup)
    end
end

macro mutate(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "mutate", tup)
    end
end

macro summarize(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "summarize", tup)
    end
end

macro group_by(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "group_by", tup)
    end
end

macro rename(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "rename", tup)
    end
end

macro transmute(pre, exprs...)
    quote
    tup = $(string(exprs))
    pipe_wrap($(esc(pre)), "transmute", tup)
    end
end

function pipe_wrap(pre::AbstractString, func::AbstractString, tup)
        return_val = ""
        for i in tup
            return_val *= i
        end
        return_val = return_val[2:end-1]
        if return_val[end] == ','
            return_val = return_val[1:end-1]
        end
        
        if return_val[1:2] == ":("
            return_val = return_val[3:end-1]
        end

        return_val = replace(return_val, r":(\w)" => s"\1")
        return_val = pre * " %>% " * func * "(" * return_val * ")"
        return_val
end


end
