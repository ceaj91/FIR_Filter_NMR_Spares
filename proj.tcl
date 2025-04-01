set root_dir [pwd]
set result_dir $root_dir/result
set release_dir $root_dir/release
file mkdir $result_dir/
set project_name "fir_filter_redudant"
set design_name "design_cnn"
set jobs_num 2

create_project $project_name $result_dir -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

add_files -norecurse ${root_dir}/projekat/txt_util.vhd
add_files -norecurse ${root_dir}/projekat/util_pkg.vhd

add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/decision_logic.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/mac.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/fir_filter_redudant.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/mac_subsystem.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/mux_param_inputs.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/switch.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/voter.vhd

add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/fir_filter_redudant_tb.vhd
add_files -norecurse ${root_dir}/projekat/fir_filtar_redundant/fir_tb_behav.wcfg

add_files -norecurse ${root_dir}/projekat/force_sig.tcl

set_property top fir_filter_redudant [current_fileset]

set_property -name {xsim.simulate.runtime} -value {50ns} -objects [get_filesets sim_1]

#update_compile_order -fileset sources_1
#launch_simulation
#source fir_filter_redudant_tb.tcl
#open_wave_config {${root_dir}/projekat/fir_filtar_redundant/fir_tb_behav.wcfg}
#restart
#run 2000 ns