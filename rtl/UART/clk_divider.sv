`timescale 1ns/1ps
module clk_divider #(
	parameter integer INPUT_CLK = 100_000_000, // board clock (E3 on Arty A7 Rev E)
	parameter integer UART_CLK  = 1_843_200    // desired oversample-rate (UART_CLK * OVERSAMPLE)
    ) (
	input  logic clk,
	input  logic rst,
	output logic baud_tick
    );

    localparam integer DIVIDER_COUNT = (UART_CLK == 0) ? 1 : (INPUT_CLK / UART_CLK);
    localparam integer COUNT_WIDTH = (DIVIDER_COUNT > 1) ? $clog2(DIVIDER_COUNT) : 1;

    logic [COUNT_WIDTH-1:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= '0;
            baud_tick <= 1'b0;
        end else begin
            if (count == DIVIDER_COUNT - 1) begin
                count <= '0;
                baud_tick <= 1'b1; // one-cycle tick at (INPUT_CLK / DIVIDER_COUNT)
            end else begin
                count <= count + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule
