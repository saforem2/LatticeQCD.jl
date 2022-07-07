module Parameters_TOML
using TOML
import ..System_parameters: Params
import ..Parameter_structs:
    Print_Physical_parameters,
    Print_Fermions_parameters,
    Print_System_control_parameters,
    Print_HMCrelated_parameters,
    struct2dict,
    initialize_fermion_parameters


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
    if isdir(log_dir) == false
        mkdir(log_dir)
    end
    logfile = pwd() * "/" * log_dir * "/" * logfilename
    load_fp = open(logfile, "a")
    value_Params[pos] = load_fp



    if haskey(parameters["Measurement set"], "measurement_basedir") &&
       haskey(parameters["System Control"], "measurement_basedir") == false
        measurement_basedir = parameters["Measurement set"]["measurement_basedir"]
        measurement_dir = parameters["Measurement set"]["measurement_dir"]
    elseif haskey(parameters["Measurement set"], "measurement_basedir") == false &&
           haskey(parameters["System Control"], "measurement_basedir")
        measurement_basedir = parameters["System Control"]["measurement_basedir"]
        measurement_dir = parameters["System Control"]["measurement_dir"]
    elseif haskey(parameters["Measurement set"], "measurement_basedir") &&
           haskey(parameters["System Control"], "measurement_basedir")
        @error "both \"Measurement set\" and \"System Control\" have \"measurement_basedir\". remove one."
    else
        measurement_basedir = parameters["Measurement set"]["measurement_basedir"]
        measurement_dir = parameters["Measurement set"]["measurement_dir"]
    end
    if isdir(measurement_basedir) == false
        mkdir(measurement_basedir)
    end

    if isdir(pwd() * "/" * measurement_basedir * "/" * measurement_dir) == false
        mkdir(pwd() * "/" * measurement_basedir * "/" * measurement_dir)
    end

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

    parameters = Params(value_Params...)

    parameter_check(parameters)

    return parameters
end

function parameter_check(p::Params)
    if p.Dirac_operator != nothing
        println("$(p.Dirac_operator) fermion is used")
    end

    if p.saveU_format ≠ nothing
        if isdir(p.saveU_dir) == false
            mkdir(p.saveU_dir)
        end
        println("$(p.saveU_dir) is used for saving configurations")
    end

    if p.update_method == "HMC"
        println("HMC will be used")
    elseif p.update_method == "Heatbath"
        println("Heatbath will be used")
    elseif p.update_method == "Fileloading"
        println("No update will be used (read-measure mode)")
        p.quench = true
    elseif p.update_method == "SLHMC"
        println("SLHMC will be used")
        if p.quench == false
            println("quench = true is set")
            p.quench = true
            #error("system[\"quench\"] = false. The SLHMC needs the quench update. Put the other system[\"update_method\"] != \"SLHMC\" or system[\"quench\"] = true")
        end
    else
        error("""
        update_method in [\"Physical setting\"] = $update_method is not supported.
        Supported methods are 
        HMC
        Heatbath
        Fileloading
        """)
    end

    log_dir = p.log_dir
    if isdir(log_dir) == false
        mkdir(log_dir)
    end



end

function construct_measurement_dir(x)
    #println(x)
    valuedic = Dict[]

    for (method, methoddic) in x
        dic_i = Dict()
        for (key, value) in methoddic
            if key == "fermion_parameters"
                fermion_type = value["Dirac_operator"]
                fermion_dict = struct2dict(initialize_fermion_parameters(fermion_type))
                for (key_i, value_i) in fermion_dict
                    if haskey(value, key_i)
                        dic_i[key_i] = value[key_i]
                    else
                        dic_i[key_i] = value_i
                    end
                end
            else
                dic_i[key] = value
            end
        end
        #println("dic_i $dic_i")
        push!(valuedic, dic_i)
    end

    #display(valuedic)

    return valuedic
end

#demo_TOML()
end
