set_property SRC_FILE_INFO {cfile:C:/Users/student/Documents/GitHub/TFE4141/rsa_term_project/Master_constraints/PYNQ-Z1_C.xdc rfile:../../../../../Master_constraints/PYNQ-Z1_C.xdc id:1} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/student/Documents/GitHub/TFE4141/rsa_term_project/RSA_soc/boards/rsa_soc_ooc.xdc rfile:../../../../boards/rsa_soc_ooc.xdc id:2} [current_design]
set_property src_info {type:XDC file:1 line:199 export:INPUT save:INPUT read:READ} [current_design]
create_clock -period 14.000 -name clk -waveform {0.000 7.000} clk
set_property src_info {type:XDC file:2 line:9 export:INPUT save:INPUT read:READ} [current_design]
create_clock -name processing_system7_0_FCLK_CLK0 -period 4 [get_pins processing_system7_0/FCLK_CLK0]
