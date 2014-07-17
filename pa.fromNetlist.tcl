
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name PDL -dir "C:/Users/praveen/Dropbox/PUF_Praveen_Bak/planAhead_run_2" -part xc5vlx110tff1136-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/praveen/Dropbox/PUF_Praveen_Bak/system.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/praveen/Dropbox/PUF_Praveen_Bak} {ipcore_dir} }
add_files [list {ipcore_dir/blk_mem_gen_inputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_outputMem.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/blk_mem_gen_paramReg.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/RMEM.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "C:/Users/praveen/Dropbox/PUF_Praveen_Bak/constraints/XUPV5system.ucf" [current_fileset -constrset]
add_files [list {C:/Users/praveen/Dropbox/PUF_Praveen_Bak/constraints/XUPV5system.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/praveen/Dropbox/PUF_Praveen_Bak/constraints/pdl_constraints.ucf}] -fileset [get_property constrset [current_run]]
link_design
