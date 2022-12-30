module TidyTable

using DataFrames: DataFrame
using RCall

export tidytable, collect, @select, @filter, @slice, @mutate, @summarize, @summarise, @group_by, @rename, @transmute, @arrange, @pull

macro_symbols = :select, :filter, :slice, :mutate, :summarize, :summarise, :group_by, :rename, :transmute, :arrange, :pull


for f in macro_symbols
    @eval begin
        macro $f(tuple, exprs...)
            quote
                call = $(string(exprs))
                pipe_wrap($(esc(tuple)), $($(string(f))), call)
            end
        end
    end    
end

function tidytable(df::DataFrame)
    R"""
    list.of.packages <- c("tidytable")
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages) > 0) install.packages(new.packages)
    
    library(tidytable)
    """

    df, "df"
end

function Base.collect(tuple::Tuple{DataFrame, AbstractString})
    df, call = tuple
    @rput df
    df = rcopy(reval(call))
    reval("rm(df)")
    df
end

function pipe_wrap(tuple::Tuple{DataFrame, AbstractString}, tidy_func::AbstractString, call::AbstractString)
        return_val = call
        return_val = replace(return_val, r"([(, ]):(\(\w)" => s"\1\2") # remove :(quoted expressions
        return_val = replace(return_val, r"([(, ]):(\w)" => s"\1\2") # remove :symbols
        return_val = replace(return_val, ",)" => ")") # remove trailing comma for tuple
        return_val = return_val[2:end-1] # remove surrounding parentheses
        return_val = replace(return_val, r"^\((.+)\)$" => s"\1")
        
        df, pre = tuple
        
        return_val = pre * " %>% " * tidy_func * "(" * return_val * ")"
        df, return_val
end


end
