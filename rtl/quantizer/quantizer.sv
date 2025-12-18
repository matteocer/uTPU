module quantizer #(
	parameter ACCUMULATOR_DATA_WIDTH = 16,
	parameter COMPUTE_DATA_WIDTH     = 4
    ) ( 
	input  logic [ACCUMULATOR_DATA_WIDTH-1:0]  in_val,
	output logic [COMPUTE_DATA_WIDTH-1:0] 	   result
    );
    
    assign out_val = in_val >> ACCUMULATOR_DATA_WIDTH - COMPUTE_DATA_WIDTH;

endmodule: quantizer
