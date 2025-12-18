module top #(
	parameter ALPHA			 = 2,
	parameter COMPUTE_DATA_WIDTH     = 4,
	parameter ACCUMULATOR_DATA_WIDTH = 16, 
	parameter ARRAY_SIZE		 = 2,
	parameter FIFO_WIDTH		 = 256,
	parameter FIFO_DATA_WIDTH	 = 8,
	parameter BUFFER_SIZE		 = 1024,
	parameter BUFFER_WORD_SIZE	 = 16,
	parameter ADDRESS_SIZE		 = $clog2(BUFFER_SIZE)

    ) (
	input logic clk, 
    );
