module Containers

import ..Coluna

import DataStructures
import Primes
import Printf
import Base: <=, setindex!, get, getindex, haskey, keys, values, iterate, 
             length, lastindex, filter, show, keys, copy

# nestedenum.jl
export NestedEnum, @nestedenum, @exported_nestedenum

# solsandbounds.jl
export Bound, Solution,
       getvalue, isbetter, diff, gap, printbounds, getbound, setvalue!

# To be deleted :
export ElemDict,
       MembersVector, MembersMatrix

export getelements, getelement, rows, cols, columns, getrecords

include("nestedenum.jl")
include("solsandbounds.jl")

# Following files will be deleted
include("elements.jl")
include("members.jl")

end