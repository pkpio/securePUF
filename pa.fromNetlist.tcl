
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name PDL -dir "C:/Users/praveen/Downloads/code-secure/planAhead_run_4" -part xc5vlx110tff1136-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/praveen/Downloads/code-secure/system.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/praveen/Downloads/code-secure} {ipcore_dir} }
add_files [list {ipcore_dir/blk_mem_gen_inputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_outputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_paramReg.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "C:/Users/praveen/Downloads/code-secure/constraints/pdl_constraints.ucf" [current_fileset -constrset]
add_files [list {C:/Users/praveen/Downloads/code-secure/constraints/pdl_constraints.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/praveen/Downloads/code-secure/constraints/puf_logic_constraints.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/praveen/Downloads/code-secure/constraints/XUPV5system.ucf}] -fileset [get_property constrset [current_run]]
link_design
