`include "mac.sv"

module mac_array #(
	parameter ARRAY_SIZE     	 = 2,
	parameter INPUT_DATA_WIDTH 	 = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16
    ) (
	input logic clk, compute, load_en, 
	input logic  [INPUT_DATA_WIDTH-1:0] 	  in          [ARRAY_SIZE-1:0],
	output logic [ACCUMULATOR_DATA_WIDTH-1:0] accumulator [ARRAY_SIZE-1:0]
    );

    genvar i;
    generate 
	for (i = 0; i < ARRAY_SIZE; i++) begin: gen_mac
	    mac #(
		.INPUT_DATA_WIDTH(INPUT_DATA_WIDTH),
		.ACCUMULATOR_DATA_WIDTH(ACCUMULATOR_DATA_WIDTH),
	    ) u_mac (
		.clk(clk),
		.load_en(load_en),
		.in(in[i]),
		.accumulator(accumulator[i])
	    );
	end
    endgenerate

endmodule: mac_array
