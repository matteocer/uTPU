module mac #(
	parameter INPUT_DATA_WIDTH  = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16
    ) (
	input  logic 			   	  clk,
	input  logic [INPUT_DATA_WIDTH-1:0]       in_a, in_b,
	output logic [ACCUMULATOR_DATA_WIDTH-1:0] accumulator 
    );
    
    always_ff @(posedge clk) begin
	accumulator <= accumulator + (in_a * in_b);
    end	

endmodule: mac
