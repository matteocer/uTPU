`timescale 1ns/1ps

module uart #(
	parameter integer UART_BITS_TRANSFERED = 8,
	parameter integer INPUT_CLK = 100_000_000,    // must match XDC E3 = 100 MHz
	parameter integer UART_CLK  = 115200,         // desired UART rate(e.g., 115200)
	parameter integer OVERSAMPLE = 16
    ) (
	input  logic clk,        // 100 MHz from E3 (XDC)
	input  logic rst,
	input  logic tx_start,
	input  logic rx,         // rx from FTDI (PC TX)
	output logic rx_valid,
	output logic tx,         // tx to FTDI (PC RX)
	input  logic [UART_BITS_TRANSFERED-1:0] tx_message,
	output logic [UART_BITS_TRANSFERED-1:0] rx_result,
	output logic tx_busy
    );

    // Compute oversampled UART clock fed to the divider
    localparam integer UART_CLK_OS = UART_CLK * OVERSAMPLE;

    logic baud_tick;
    logic rx_valid_uart;
    logic [UART_BITS_TRANSFERED-1:0] rx_result_uart;
    logic rx_valid_d;

    // Divider: produces one-cycle baud_tick at (INPUT_CLK / UART_CLK_OS)
    clk_divider #(
        .INPUT_CLK(INPUT_CLK),
        .UART_CLK(UART_CLK_OS)
    ) u_clk_divider (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Receiver
    uart_receiver #(
        .UART_BITS_TRANSFERED(UART_BITS_TRANSFERED),
        .OVERSAMPLE(OVERSAMPLE)
    ) u_uart_receiver (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .rx(rx),
        .valid(rx_valid_uart),
        .result(rx_result_uart)
    );

    // Transmitter
    uart_transmitter #(
        .UART_BITS_TRANSFERED(UART_BITS_TRANSFERED),
        .OVERSAMPLE(OVERSAMPLE)
    ) u_uart_transmitter (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .start(tx_start),
        .tx(tx),
        .message(tx_message),
        .busy(tx_busy)
    );

    // Optional: register outputs so external logic sees stable values
    // Convert the receiver's level-valid into a single-cycle pulse so downstream
    // logic only enqueues each received byte once.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_valid    <= 1'b0;
            rx_valid_d  <= 1'b0;
            rx_result   <= '0;
        end else begin
            rx_valid_d  <= rx_valid_uart;
            rx_valid    <= rx_valid_uart && ~rx_valid_d; // one-cycle pulse
            // Keep the latest byte visible even after the pulse
            rx_result   <= rx_result_uart;
        end
    end

endmodule: uart
