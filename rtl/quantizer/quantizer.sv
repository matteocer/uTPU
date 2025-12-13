module quantizer (
	input logic [15:0] in_val,
	output logic [3:0] result
    );
    
    assign out_val = in_val >> 12;

endmodule: quantizer
