# aclk {FREQ_HZ 50000000 CLK_DOMAIN rsa_soc_processing_system7_0_0_FCLK_CLK0 PHASE 0.0}
# Clock Domain: rsa_soc_processing_system7_0_0_FCLK_CLK0
create_clock -name aclk -period 20.000 [get_ports aclk]
# Generated clocks