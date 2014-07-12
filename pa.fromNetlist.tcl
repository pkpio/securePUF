
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name PDL -dir "E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/planAhead_run_1" -part xc5vlx110tff1136-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/system.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code} {ipcore_dir} }
add_files [list {ipcore_dir/blk_mem_gen_inputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_outputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_paramReg.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/constraints/pdl_constraints.ucf" [current_fileset -constrset]
add_files [list {E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/constraints/pdl_constraints.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/constraints/puf_logic_constraints.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {E:/Dropbox/Works and collections/Elec/Rice/PDL/Hardware/code/constraints/XUPV5system.ucf}] -fileset [get_property constrset [current_run]]
open_netlist_design
