
`timescale 1ns/1ps
module uart_transmitter #(
	parameter integer UART_BITS_TRANSFERED = 8,
	parameter integer OVERSAMPLE = 16
    ) (
	input  logic clk,
	input  logic rst,
	input  logic baud_tick,            // step every oversample tick
	input  logic start,
	output logic tx,
	input  logic [UART_BITS_TRANSFERED-1:0] message,
	output logic busy
    );

    typedef enum logic [1:0] { IDLE, START, MESSAGE, STOP } state_e;
    state_e current_state;

    integer transmitting_bit;
    integer tick_count;
    logic start_pending;
    logic [UART_BITS_TRANSFERED-1:0] latched_message;

    // initialize
    initial begin
        tx = 1'b1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            transmitting_bit <= 0;
            tick_count <= 0;
            tx <= 1'b1;
            start_pending <= 1'b0;
            latched_message <= '0;
        end else begin
            // Latch start request and message so start can be honored on a later baud_tick.
            if (start && !start_pending && current_state == IDLE) begin
                start_pending <= 1'b1;
                latched_message <= message;
            end

            if (baud_tick) begin
                case (current_state)
                    IDLE: begin
                        tx <= 1'b1;
                        if (start_pending) begin
                            current_state <= START;
                            tick_count <= OVERSAMPLE - 1;
                            transmitting_bit <= 0;
                            start_pending <= 1'b0;
                        end
                    end
                    START: begin
                        tx <= 1'b0;
                        if (tick_count == 0) begin
                            current_state <= MESSAGE;
                            tick_count <= OVERSAMPLE - 1;
                            transmitting_bit <= 0;
                        end else begin
                            tick_count <= tick_count - 1;
                        end
                    end
                    MESSAGE: begin
                        tx <= latched_message[transmitting_bit];
                        if (tick_count == 0) begin
                            if (transmitting_bit == UART_BITS_TRANSFERED - 1) begin
                                current_state <= STOP;
                                tick_count <= OVERSAMPLE - 1;
                                transmitting_bit <= 0;
                            end else begin
                                transmitting_bit <= transmitting_bit + 1;
                                tick_count <= OVERSAMPLE - 1;
                            end
                        end else begin
                            tick_count <= tick_count - 1;
                        end
                    end
                    STOP: begin
                        tx <= 1'b1;
                        if (tick_count == 0) begin
                            current_state <= IDLE;
                        end else begin
                            tick_count <= tick_count - 1;
                        end
                    end
                    default: begin
                        current_state <= IDLE;
                    end
                endcase
            end
        end
    end

    assign busy = (current_state != IDLE) || start_pending;

endmodule: uart_transmitter
