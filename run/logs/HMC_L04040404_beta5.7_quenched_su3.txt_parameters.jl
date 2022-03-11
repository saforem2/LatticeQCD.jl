# - - parameters - - - - - - - - - - - 
# Physical setting 
system["L"] = (4, 4, 4, 4)
system["β"] = 5.7
system["NC"] = 3
system["Nthermalization"] = 0
system["Nsteps"] = 5
system["initial"] = "cold"
system["initialtrj"] = 1
system["update_method"] = "HMC"
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
system["logfile"] = "HMC_L04040404_beta5.7_quenched_su3.txt"
system["saveU_dir"] = ""
system["saveU_format"] = nothing
system["saveU_every"] = 1
system["verboselevel"] = 2
system["randomseed"] = 111
measurement["measurement_basedir"] = "./measurements"
measurement["measurement_dir"] = "HMC_L04040404_beta5.7_quenched_su3"
system["julian_random_number"] = false
	
# HMC related
md["Δτ"] = 0.06666666666666667
md["SextonWeingargten"] = false
md["N_SextonWeingargten"] = 2
md["MDsteps"] = 15
cg["eps"] = 1.0e-19
cg["MaxCGstep"] = 3000
	
# Action parameter for SLMC
actions["use_autogeneratedstaples"] = false
actions["couplingcoeff"] = Any[]
actions["couplinglist"] = Any[]
actions["coupling_loops"] = nothing
	
# Measurement set
measurement["measurement_methods"] = Dict[ 
  Dict{Any,Any}("methodname" => "Chiral_condensate",
    "eps" => 1.0e-19,
    "fermiontype" => "Staggered",
    "Nf" => 4,
    "mass" => 0.5,
    "measure_every" => 5,
    "MaxCGstep" => 3000
  ),
  Dict{Any,Any}("methodname" => "Polyakov_loop",
    "measure_every" => 1
  ),
  Dict{Any,Any}("methodname" => "Topological_charge",
    "Nflowsteps" => 4,
    "numflow" => 10,
    "measure_every" => 10,
    "eps_flow" => 0.01
  ),
  Dict{Any,Any}("methodname" => "Pion_correlator",
    "eps" => 1.0e-19,
    "fermiontype" => "Wilson",
    "r" => 1,
    "measure_every" => 5,
    "hop" => 0.141139,
    "MaxCGstep" => 3000
  ),
  Dict{Any,Any}("methodname" => "Plaquette",
    "measure_every" => 1
  )
]
	
# - - - - - - - - - - - - - - - - - - -
