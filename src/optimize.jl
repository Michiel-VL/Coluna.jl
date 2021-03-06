function _welcome_message()
    welcome = """
    Coluna
    Version 0.2 - https://github.com/atoptima/Coluna.jl
    """
    print(welcome)
end

"""
Starting point of the solver.
"""
function optimize!(prob::MP.Problem, annotations::MP.Annotations, params::Params)
    _welcome_message()
    _set_global_params(params)
    reformulate!(prob, annotations)
    _globals_.initial_solve_time = time()
    MP.relax_integrality!(prob.re_formulation.master) # TODO : remove
    @info "Coluna ready to start."
    @info _params_
    TO.@timeit _to "Coluna" begin
        opt_result = optimize!(prob.re_formulation, params.global_strategy)
    end
    println(_to)
    TO.reset_timer!(_to)
    @logmsg LogLevel(1) "Terminated"
    @logmsg LogLevel(1) string("Primal bound: ", getprimalbound(opt_result))
    @logmsg LogLevel(1) string("Dual bound: ", getdualbound(opt_result))
    return opt_result
end

# TODO : Replace AbstractGlobalStrategy by a "Solver"
# TODO : Rm run_reform_solver (ReformulationSolver to delete)
"""
Solve a reformulation
"""
function optimize!(
        reform::MP.Reformulation, strategy::AbstractGlobalStrategy
    )
    Algorithm.prepare!(strategy, reform)
    opt_result = Algorithm.run_reform_solver!(reform, strategy) 
    master = getmaster(reform)
    for (idx, sol) in enumerate(getprimalsols(opt_result))
        opt_result.primal_sols[idx] = proj_cols_on_rep(sol, master)
    end
    return opt_result
end
