module pe_controller #(
	parameter ARRAY_SIZE 		 = 8,
	parameter ARRAY_SIZE_WIDTH 	 = $clog2(ARRAY_SIZE),
	parameter COMPUTE_DATA_WIDTH     = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16,
	parameter BUFFER_WORD_SIZE       = 16,
	parameter NUM_COMPUTE_LANES      = BUFFER_WORD_SIZE/COMPUTE_DATA_WIDTH
    ) (
	input  logic clk, rst, compute, load_en,
	input  logic signed [COMPUTE_DATA_WIDTH-1:0]     datas_arr   [ARRAY_SIZE*ARRAY_SIZE-1:0],
	input  logic signed [COMPUTE_DATA_WIDTH-1:0]     weights_in  [ARRAY_SIZE*ARRAY_SIZE-1:0],
	output logic signed [ACCUMULATOR_DATA_WIDTH-1:0] results_arr [ARRAY_SIZE*ARRAY_SIZE-1:0]
    );
    
    localparam CYCLE_LENGTH = ARRAY_SIZE*2-1;

    logic        [$clog2(CYCLE_LENGTH)-1:0]   cycle_count;
    logic signed [COMPUTE_DATA_WIDTH-1:0]     datas_in [ARRAY_SIZE-1:0];
    logic signed [ACCUMULATOR_DATA_WIDTH-1:0] results  [ARRAY_SIZE-1:0];
   
    always_ff @(posedge clk) begin
	if (rst)
	    cycle_count <= '0;
	else begin
	    if (cycle_count == CYCLE_LENGTH) 
		cycle_count <= '0;
	    datas_in[0] <= (cycle_count < ARRAY_SIZE) ? datas_arr[ARRAY_SIZE*cycle_count] : '0;
	    datas_in[1] <= (cycle_count < ARRAY_SIZE+1 && cycle_count > 0) ? datas_arr[ARRAY_SIZE*cycle_count + 1] : '0;
	    datas_in[2] <= (cycle_count < ARRAY_SIZE+2 && cycle_count > 1) ? datas_arr[ARRAY_SIZE*cycle_count + 2] : '0;
	    datas_in[3] <= (cycle_count < ARRAY_SIZE+3 && cycle_count > 2) ? datas_arr[ARRAY_SIZE*cycle_count + 3] : '0;
	    datas_in[4] <= (cycle_count < ARRAY_SIZE+4 && cycle_count > 3) ? datas_arr[ARRAY_SIZE*cycle_count + 4] : '0;
	    datas_in[5] <= (cycle_count < ARRAY_SIZE+5 && cycle_count > 4) ? datas_arr[ARRAY_SIZE*cycle_count + 5] : '0;
	    datas_in[6] <= (cycle_count < ARRAY_SIZE+6 && cycle_count > 5) ? datas_arr[ARRAY_SIZE*cycle_count + 6] : '0;
	    datas_in[7] <= (cycle_count < ARRAY_SIZE+7 && cycle_count > 6) ? datas_arr[ARRAY_SIZE*cycle_count + 7] : '0;
	end
    end

    pe_array #(
	.ARRAY_SIZE(ARRAY_SIZE),
	.ARRAY_SIZE_WIDTH(ARRAY_SIZE_WIDTH),
	.COMPUTE_DATA_WIDTH(COMPUTE_DATA_WIDTH),
	.ACCUMULATOR_DATA_WIDTH(ACCUMULATOR_DATA_WIDTH),
	.BUFFER_WORD_SIZE(BUFFER_WORD_SIZE),
	.NUM_COMPUTE_LANES(NUM_COMPUTE_LANES)
    ) u_pe_array (
	.clk(clk),
	.rst(rst),
	.compute(compute),
	.load_en(load_en),
	.datas_in(datas_in),
	.weights_in(weights_in),
	.results(results)
    );

endmodule: pe_controller
