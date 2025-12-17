module mac #(
	parameter INPUT_DATA_WIDTH  = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16
    ) (
	input  logic 			   	  clk, compute, load_en,
	input  logic [INPUT_DATA_WIDTH-1:0]       in,
	output logic [ACCUMULATOR_DATA_WIDTH-1:0] accumulator 
    );
   
    logic [INPUT_DATA_WIDTH-1:0] weight;
    always_ff @(posedge clk) begin
	if (load_en) 
	    weight <= in;
	else if (compute)
	    accumulator <= accumulator + (in * weight);
    end	

endmodule: mac
