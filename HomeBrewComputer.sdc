create_clock -name clk -period 10.000 clk

# Constrain the input I/O path 
set_input_delay -clock clk -max 3 [all_inputs] 
set_input_delay -clock clk -min 2 [all_inputs] 
 
# Constrain the output I/O path 
set_output_delay -clock clk -max 3 [all_outputs]
set_output_delay -clock clk -min 2 [all_outputs]
