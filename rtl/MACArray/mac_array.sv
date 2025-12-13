`include "mac.sv"

module mac_array #(
	parameter ARRAY_SIZE     	 = 2,
	parameter INPUT_DATA_WIDTH 	 = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16
    ) (
	input logic clk, 
	input logic  [ARRAY_SIZE-1:0] in_a   [INPUT_DATA_WIDTH-1:0],
	input logic  [ARRAY_SIZE-1:0] in_b   [INPUT_DATA_WIDTH-1:0],
	output logic [ARRAY_SIZE-1:0] accumulator [ACCUMULATOR_DATA_WIDTH-1:0]
    );

    genvar i;
    generate 
	for (i = 0; i < ARRAY_SIZE; i++) begin: gen_mac
	    mac mac_0 (.*);
	end
    endgenerate

endmodule: mac_array
