create_clock -name clk_in -period 12 clk_in
# Constrain the input I/O path 
set_input_delay -clock clk_in -max 3 [all_inputs] 
set_input_delay -clock clk_in -min 2 [all_inputs] 
 
# Constrain the output I/O path 
set_output_delay -clock clk_in -max 3 [all_outputs]
set_output_delay -clock clk_in -min 2 [all_outputs]

derive_clock_uncertainty