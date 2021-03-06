function clonevar!(originform::Formulation,
                   destform::Formulation,
                   assignedform::Formulation,
                   var::Variable,
                   duty::AbstractVarDuty;
                   name::String = getname(var),
                   cost::Float64 = getperenecost(originform, var),
                   lb::Float64 = getperenelb(originform, var),
                   ub::Float64 = getpereneub(originform, var),
                   kind::VarKind = getperenekind(originform, var),
                   sense::VarSense = getperenesense(originform, var),
                   inc_val::Float64 = getpereneincval(originform, var),
                   is_active::Bool = get_init_is_active(var),
                   is_explicit::Bool = get_init_is_explicit(var),
                   members::Union{ConstrMembership,Nothing} = nothing)
    return setvar!(
        destform, name, duty; cost = cost, lb = lb, ub = ub, kind = kind, 
        sense = sense, inc_val = inc_val, is_active = is_active,
        is_explicit = is_explicit, members = members,
        id = Id{Variable}(getid(var), getuid(assignedform))
    )
end

function cloneconstr!(originform::Formulation,
                      destform::Formulation,
                      assignedform::Formulation,
                      constr::Constraint,
                      duty::AbstractConstrDuty;
                      name::String = getname(constr),
                      rhs::Float64 = getperenerhs(constr),
                      kind::ConstrKind = getperenekind(originform, constr),
                      sense::ConstrSense = getperenesense(originform, constr),
                      inc_val::Float64 = getpereneincval(originform, constr),
                      is_active::Bool = get_init_is_active(constr),
                      is_explicit::Bool = get_init_is_explicit(constr),
                      members::Union{VarMembership,Nothing}  = nothing)
    return setconstr!(
        destform, name, duty, rhs = rhs, kind = kind, sense = sense, 
        inc_val = inc_val, is_active = is_active, is_explicit = is_explicit,
        members = members,
        id = Id{Constraint}(getid(constr), getuid(assignedform))
    )
end

function clonecoeffs!(originform::Formulation,
                      destform::Formulation)
    dest_matrix = getcoefmatrix(destform)
    orig_matrix = getcoefmatrix(originform)
    for (cid, constr) in getconstrs(destform)
        if haskey(originform, cid)
            for (vid, var) in getvars(destform)
                if haskey(originform, vid)
                    val = orig_matrix[cid, vid]
                    if val != 0
                        dest_matrix[cid, vid] = val
                    end
                end
            end
        end
    end
    return
end
