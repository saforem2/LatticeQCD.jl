module Parameters_TOML
using TOML
import ..System_parameters: Params
import ..Parameter_structs:
    Print_Physical_parameters,
    Print_Fermions_parameters,
    Print_System_control_parameters,
    Print_HMCrelated_parameters,
    struct2dict

function demo_TOML()
    println("demo for TOML format")
    p = construct_Params_from_TOML("parametertest.toml")
end


function set_params_value!(value_Params, values)
    d = struct2dict(values)
    pnames = fieldnames(Params)
    for (i, pname_i) in enumerate(pnames)
        if haskey(d, String(pname_i))
            if d[String(pname_i)] == "nothing" && String(pname_i) != "smearing_for_fermion"
                value_Params[i] = nothing
            else
                value_Params[i] = d[String(pname_i)]
            end
        end
    end
end

const unused_bool_values = ["use_autogeneratedstaples", "integratedFermionAction"]
const unused_array_values = ["couplinglist", "couplingcoeff"]
const unused_int_values = ["firstlearn"]
const unused_float_values = ["βeff"]

const unused_nothing_values = ["coupling_loops"]

const unused_string_values = ["training_data_name"]


function set_unused_parameters!(value_Params)
    pnames = fieldnames(Params)
    for (i, pname_i) in enumerate(pnames)
        valuename = String(pname_i)
        if findfirst(x -> x == valuename, unused_bool_values) != nothing
            value_Params[i] = false
        elseif findfirst(x -> x == valuename, unused_array_values) != nothing
            value_Params[i] = []
        elseif findfirst(x -> x == valuename, unused_int_values) != nothing
            value_Params[i] = 0
        elseif findfirst(x -> x == valuename, unused_float_values) != nothing
            value_Params[i] = 0.0
        elseif findfirst(x -> x == valuename, unused_nothing_values) != nothing
            value_Params[i] = nothing
        elseif findfirst(x -> x == valuename, unused_string_values) != nothing
            value_Params[i] = ""
        end
    end
end


function construct_Params_from_TOML(filename)
    parameters = TOML.parsefile(filename)
    #display(parameters)
    #println("\t")
    pnames = fieldnames(Params)
    numparams = length(pnames)
    value_Params = Vector{Any}(undef, numparams)

    physical = Print_Physical_parameters()
    set_params_value!(value_Params, physical)
    fermions = Print_Fermions_parameters()
    set_params_value!(value_Params, fermions)
    control = Print_System_control_parameters()
    set_params_value!(value_Params, control)
    hmc = Print_HMCrelated_parameters()
    set_params_value!(value_Params, hmc)

    set_unused_parameters!(value_Params)

    #println(pnames)
    pos = findfirst(x -> String(x) == "ITERATION_MAX", pnames)
    value_Params[pos] = 10^5

    pos = findfirst(x -> String(x) == "isevenodd", pnames)
    value_Params[pos] = true

    pos = findfirst(x -> String(x) == "load_fp", pnames)
    logfilename = parameters["System Control"]["logfile"]
    log_dir = parameters["System Control"]["log_dir"]
    logfile = pwd() * "/" * log_dir * "/" * logfilename
    load_fp = open(logfile, "a")
    value_Params[pos] = load_fp

    measurement_basedir = parameters["Measurement set"]["measurement_basedir"]
    measurement_dir = parameters["Measurement set"]["measurement_dir"]
    pos = findfirst(x -> String(x) == "measuredir", pnames)
    measuredir = pwd() * "/" * measurement_basedir * "/" * measurement_dir
    value_Params[pos] = measuredir

    for (i, pname_i) in enumerate(pnames)
        #println("before $(value_Params[i])")
        for (key, value) in parameters
            if haskey(value, String(pname_i))
                #println("$pname_i $key ",value[String(pname_i)])
                if String(pname_i) == "measurement_methods"
                    #println("$pname_i $key ",value[String(pname_i)])
                    valuedir = construct_measurement_dir(value[String(pname_i)])
                    value_Params[i] = valuedir
                elseif String(pname_i) == "L"
                    value_Params[i] = Tuple(value[String(pname_i)])
                else
                    if value[String(pname_i)] == "nothing" &&
                       String(pname_i) != "smearing_for_fermion"
                        value_Params[i] = nothing
                    else
                        value_Params[i] = value[String(pname_i)]
                    end


                end


            end
        end

        if isassigned(value_Params, i) == false
            @error "$(pname_i) is not defined!"
        end

        #println(pname_i,"::$(typeof(value_Params[i])) $(value_Params[i])")

    end



    return Params(value_Params...)
end

function construct_measurement_dir(x)
    valuedir = Dict[]
    @error "not done!"
    return valuedir
end
end
