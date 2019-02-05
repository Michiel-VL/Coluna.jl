# Basic example

This quick start guide introduces features of Coluna.jl package.

## Model instantiation

A JuMP model using Coluna model can be instantiated as

```julia
  using JuMP
  import Coluna
  gap = Model(with_optimizer(Coluna.Optimizer))
```  

## Write the model

The model is written as a JuMP model. If you are not familiar with JuMP syntax,
you may want to check its [documentation]
(https://jump.readthedocs.io/en/latest/quickstart.html#defining-variables).

Consider a set of machines `Machines = 1:M` and a set of jobs `Jobs = 1:J`.
A machine `m` has a resource capacity `Capacity[m]`. When we assign a job
`j` to a machine `m`, the job has a cost `Cost[m,j]` and consumes
`Weight[m,j]` resources of the machine `m`. The goal is to minimize the jobs
cost sum by assigning each job to a machine while not exceeding the capacity of
each machine. The model is:

```julia
@variable(gap, x[m in data.machines, j in data.jobs], Bin)

@constraint(gap, cov[j in data.jobs],
        sum(x[m,j] for m in data.machines) >= 1)

@constraint(gap, knp[m in data.machines],
        sum(data.weight[j, m] * x[m, j] for j in data.jobs) <= data.capacity[m])

@objective(gap, Min,
        sum(data.cost[j, m] * x[m, j] for m in data.machines, j in data.jobs))
```

## Decomposition

The decomposition is described through the following annotations:

```julia
# setting constraint annotations for the decomposition
for j in data.jobs
    set(gap, Coluna.ConstraintDantzigWolfeAnnotation(), cov[j], 0)
end
for m in data.machines
    set(gap, Coluna.ConstraintDantzigWolfeAnnotation(), knp[m], m)
end

# setting variable annotations for the decomposition
for m in data.machines, j in data.jobs
    set(gap, Coluna.VariableDantzigWolfeAnnotation(), x[m, j], m)
end
```

The decomposition can also be described in a more compact functional way:

```julia
function gap_decomp_func(name, key)
    if name in [:knp, :x]
        return key[1]
    else
        return 0
    end
end
Coluna.set_dantzig_wolfe_decompostion(gap, gap_decomp_func)
```

Now you can solve the problem and get the solution values as you do with
JuMP when using any other Optimizer.

## Logs

Here is an example of the solver's basic log

```julia
************************************************************
Preparing root node for treatment.
1 open nodes. Treating node 1.
Current best known bounds : [ -Inf , Inf ]
************************************************************
<it=1> <cols=3> <mlp=1.0e6> <DB=-1.999989e6> <PB=1.0e6>
<it=2> <cols=3> <mlp=1.0e6> <DB=-1.999973e6> <PB=1.0e6>
<it=3> <cols=3> <mlp=1.0e6> <DB=-1.999961e6> <PB=1.0e6>
<it=4> <cols=3> <mlp=1.0e6> <DB=-1.99996e6> <PB=1.0e6>
<it=5> <cols=3> <mlp=1.0e6> <DB=-1.99996e6> <PB=1.0e6>
<it=6> <cols=3> <mlp=13.0> <DB=8.0> <PB=13.0>
<it=7> <cols=3> <mlp=13.0> <DB=12.0> <PB=13.0>
<it=8> <cols=3> <mlp=13.0> <DB=12.0> <PB=13.0>
<it=9> <cols=3> <mlp=13.0> <DB=13.0> <PB=13.0>
Node is conquered, no need for branching.
New incumbent IP solution with cost: 13.0
 ──────────────────────────────────────────────────────────────────────────────────────
                                               Time                   Allocations      
                                       ──────────────────────   ───────────────────────
           Tot / % measured:                11.4s / 25.9%           1.18GiB / 20.5%    

 Section                       ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────────────
 run_eval_by_col_gen                1    2.95s   100%   2.95s    248MiB  100%    248MiB
   solve_restricted_mast            9    2.11s  71.3%   234ms    190MiB  76.7%  21.1MiB
   gen_new_col                     27    449ms  15.2%  16.6ms   35.3MiB  14.2%  1.31MiB
     insert_cols_in_master         27    272ms  9.22%  10.1ms   24.8MiB  10.0%   939KiB
     optimize!(pricing_prob)       27    112ms  3.79%  4.15ms   7.99MiB  3.22%   303KiB
     update_pricing_prob           27   61.8ms  2.09%  2.29ms   2.49MiB  1.00%  94.3KiB
 ──────────────────────────────────────────────────────────────────────────────────────
```

For every node, we print the best known primal and dual bounds. Within a node,
and for each column generation iteration, we print:

- the objective value of the restricted master LP `mlp`
- the number of columns added to the restricted master `cols`
- the computed lagrangian dual bound in this iteration `DB`
- the best integer primal bound `PB`

We also use TimerOutputs.jl package to print, at the end of the resolution,
the time consumed and the allocations made in most critical sections.

## Other Examples

Other examples are available [here]
(https://github.com/atoptima/Coluna.jl/tree/master/examples)