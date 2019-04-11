mutable struct Problem <: AbstractProblem
    name::String
    original_formulation::Union{Nothing, Formulation}
    re_formulation::Union{Nothing, Reformulation}

    var_counter::VarCounter # Can be local to Formulation
    constr_counter::ConstrCounter # Can be local to Formulation
    form_counter::FormCounter

    vars_per_block::Dict{Int, Vector{Variable}}
    constrs_per_block::Dict{Int, Vector{Constraint}}
    annotation_set::Set{BD.Annotation}

    timer_output::TimerOutputs.TimerOutput
    params::Params
    master_factory::Union{Nothing, JuMP.OptimizerFactory}
    pricing_factory::Union{Nothing, JuMP.OptimizerFactory}
    #problemidx_optimizer_map::Dict{Int, MOI.AbstractOptimizer}
end

function Problem(params::Params, master_factory, pricing_factory)
    return Problem(
        "prob", nothing, nothing, VarCounter(), ConstrCounter(), FormCounter(),
        Dict{Int, Vector{Variable}}(),
        Dict{Int, Vector{Constraint}}(),
        Set{BD.Annotation}(),
        TimerOutputs.TimerOutput(),
        params, master_factory, pricing_factory
    )
end

function set_original_formulation!(m::Problem, of::Formulation)
    m.original_formulation = of
    return
end

function set_re_formulation!(m::Problem, r::Reformulation)
    m.re_formulation = r
    return
end

get_original_formulation(m::Problem) = m.original_formulation
get_re_formulation(m::Problem) = m.re_formulation


_red(s::String) = string("\e[1;31m ", s, " \e[00m")
_green(s::String) = string("\e[1;32m ", s, " \e[00m")
_pink(s::String) = string("\e[1;35m ", s, " \e[00m")
function call_attention()
    for i in 1:10
        print(_red("!"))
        print(_green("!"))
        print(_pink("!"))
    end
    println()
end

function load_problem_in_optimizer(prob::Problem)
    load_problem_in_optimizer(prob.re_formulation)
end

function initialize_moi_optimizer(prob::Problem)
    initialize_moi_optimizer(
        prob.re_formulation, prob.master_factory, prob.pricing_factory
    )
    println(_pink("---------------> Problems loaded to MOI <---------------------------"))
end

function coluna_initialization(prob::Problem)
 
    _set_global_params(prob.params)
    reformulate!(prob, DantzigWolfeDecomposition)
    initialize_moi_optimizer(prob)
    load_problem_in_optimizer(prob)

    call_attention()
end

# # Behaves like optimize!(problem::Problem), but sets parameters before
# # function optimize!(problem::Reformulation)

function optimize!(prob::Problem)
    coluna_initialization(prob)
    global __initial_solve_time = time()
    @show _params_
    @timeit prob.timer_output "Solve prob" begin
        status = optimize!(prob.re_formulation)
    end
    println(prob.timer_output)
end
