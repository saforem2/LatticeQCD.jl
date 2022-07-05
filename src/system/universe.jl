module Universe_module
import ..System_parameters: Params
using Gaugefields
using LatticeDiracOperators

struct Univ{Dim,TG,T_FA}
    L::NTuple{Dim,Int64}
    NC::Int64
    Nwing::Int8
    gauge_action::GaugeAction{Dim,TG}
    U::Vector{TG}
    quench::Bool
    fermi_action::T_FA
    #Uold::Vector{TG}

end

function get_gauge_action(univ::Univ)
    return univ.gauge_action
end

function is_quenched(univ::Univ)
    return univ.quench
end


function Univ(p::Params)
    Dim = length(p.L)
    L = Tuple(p.L)
    NC = p.NC
    Nwing = p.Nwing

    if p.initial == "cold" || p.initial == "hot" || p.initial == "one instanton"
        if Dim == 2
            U = Initialize_Gaugefields(NC, Nwing, L..., condition = p.initial)
        else
            U = Initialize_Gaugefields(NC, Nwing, L..., condition = p.initial)
        end
    else
        if Dim == 2
            U = Initialize_Gaugefields(NC, Nwing, L..., condition = "cold")
        else
            U = Initialize_Gaugefields(NC, Nwing, L..., condition = "cold")
        end

        println_verbose_level2(U[1], ".....  File start")
        println_verbose_level1(U[1], "File name is $(p.initial)")
        if p.loadU_format == "ILDG"
            ildg = ILDG(p.initial)
            i = 1
            load_gaugefield!(U, i, ildg, L, NC)
        elseif p.loadU_format == "BridgeText"
            filename = p.initial
            load_BridgeText!(filename, U, L, NC)
        else
            error("loadU_format should be ILDG or BridgeText. Now $(p.loadU_format)")
        end
    end


    #Uold = similar(U)

    gauge_action = GaugeAction(U)

    if p.use_autogeneratedstaples
        error("p.use_autogeneratedstaples = true is not supported yet!")
    else
        plaqloop = make_loops_fromname("plaquette", Dim = Dim)
        append!(plaqloop, plaqloop')
        βinp = p.β / 2
        push!(gauge_action, βinp, plaqloop)
    end

    TG = eltype(U)
    #println(TG)
    #show(gauge_action)

    if p.Dirac_operator == nothing
        fermi_action = nothing
    else
        params = Dict()
        parameters_action = Dict()

        if p.Dirac_operator == "Staggered"
            x = Initialize_pseudofermion_fields(U[1], "staggered")
            params["Dirac_operator"] = "staggered"
            params["mass"] = p.mass
            parameters_action["Nf"] = p.Nf
        elseif p.Dirac_operator == "Wilson"
            x = Initialize_pseudofermion_fields(U[1], "Wilson", nowing = true)
            params["Dirac_operator"] = "Wilson"
            params["κ"] = p.hop
            params["r"] = p.r
            params["faster version"] = true

        elseif p.Dirac_operator == "Domainwall"
            L5 = p.Domainwall_L5
            M = p.Domainwall_M
            mass = p.Domainwall_m
            params["Dirac_operator"] = "Domainwall"
            params["mass"] = mass
            params["L5"] = L5
            params["M"] = M
            x = Initialize_pseudofermion_fields(U[1], "Domainwall", L5 = L5)
        else
            error("not supported")
        end
        params["eps_CG"] = p.eps
        params["verbose_level"] = 2
        params["MaxCGstep"] = p.MaxCGstep
        params["boundarycondition"] = p.BoundaryCondition

        D = Dirac_operator(U, x, params)
        fermi_action = FermiAction(D, parameters_action)
    end

    T_FA = typeof(fermi_action)
    return Univ{Dim,TG,T_FA}(L, NC, Nwing, gauge_action, U, p.quench, fermi_action)

end

end
