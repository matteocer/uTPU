module leaky_relu #(
	parameter A = 2
    ) (	
	input  logic [3:0] in,
	output logic [3:0] result
    );
    
    always_comb begin
	if (in > 0)
	    result = in;
	else
	    result = in >>> A;
    end

endmodule: leaky_relu
