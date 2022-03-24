# - - parameters - - - - - - - - - - - 
# Physical setting 
system["L"] = (4, 4, 4, 4)
system["β"] = 5.7
system["NC"] = 3
system["Nthermalization"] = 0
system["Nsteps"] = 100
system["initial"] = "cold"
system["initialtrj"] = 1
system["update_method"] = "Fileloading"
system["Nwing"] = 1
	
# Physical setting(fermions)
system["quench"] = true
system["Dirac_operator"] = nothing
wilson["Clover_coefficient"] = 0
wilson["r"] = 1
wilson["hop"] = 0
staggered["Nf"] = 0
staggered["mass"] = 0
system["BoundaryCondition"] = [1, 1, 1, -1]
	
# System Control
system["log_dir"] = "./logs"
system["logfile"] = "Fileloading_L04040404_beta5.7.txt"
system["loadU_format"] = "ILDG"
system["loadU_dir"] = "./confs"
system["loadU_fromfile"] = false
system["saveU_dir"] = ""
system["saveU_format"] = nothing
system["saveU_every"] = 1
system["verboselevel"] = 2
system["randomseed"] = 111
measurement["measurement_basedir"] = "./measurements"
measurement["measurement_dir"] = "Fileloading_L04040404_beta5.7"
system["julian_random_number"] = false
	
# HMC related
md["Δτ"] = 0.05
md["SextonWeingargten"] = false
md["MDsteps"] = 20
cg["eps"] = 1.0e-19
cg["MaxCGstep"] = 3000
	
# Action parameter for SLMC
actions["use_autogeneratedstaples"] = false
actions["couplingcoeff"] = Any[]
actions["couplinglist"] = Any[]
actions["coupling_loops"] = nothing
	
# Measurement set
measurement["measurement_methods"] = Dict[ 
  Dict{Any,Any}("methodname" => "Polyakov_loop",
    "measure_every" => 1
  ),
  Dict{Any,Any}("methodname" => "Topological_charge",
    "Nflowsteps" => 1,
    "numflow" => 1,
    "measure_every" => 1,
    "eps_flow" => 0.01
  ),
  Dict{Any,Any}("methodname" => "Plaquette",
    "measure_every" => 1
  )
]
	
# - - - - - - - - - - - - - - - - - - -
