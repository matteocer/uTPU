`timescale 1ns/1ps
module uart_receiver #(
    parameter integer UART_BITS_TRANSFERED = 8,
    parameter integer OVERSAMPLE = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic baud_tick,               // step every oversample tick
    input  logic rx,
    output logic valid,
    output logic [UART_BITS_TRANSFERED-1:0] result
);

    typedef enum logic [1:0] { IDLE, START, DATA, STOP } state_e;
    state_e current_state;

    integer received_bit;
    integer sample_count;

    // Synchronize async RX line to internal clock to reduce metastability/glitches.
    logic rx_meta, rx_sync;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    // initialize outputs
    initial begin
        valid = 1'b0;
        result = '0;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            valid <= 1'b0;
            received_bit <= 0;
            sample_count <= 0;
            result <= '0;
        end else begin
            // default
            if (baud_tick) begin
                valid <= 1'b0;
                case (current_state)
                    IDLE: begin
                        if (~rx_sync) begin
                            sample_count <= OVERSAMPLE / 2; // sample in the middle of start bit
                            current_state <= START;
                        end
                    end
                    START: begin
                        if (sample_count == 0) begin
                            if (~rx_sync) begin
                                received_bit <= 0;
                                sample_count <= OVERSAMPLE;
                                current_state <= DATA;
                            end else begin
                                current_state <= IDLE; // false start
                            end
                        end else begin
                            sample_count <= sample_count - 1;
                        end
                    end
                    DATA: begin
                        if (sample_count == 0) begin
                            result[received_bit] <= rx_sync;
                            received_bit <= received_bit + 1;
                            sample_count <= OVERSAMPLE;
                            if (received_bit == UART_BITS_TRANSFERED-1) begin
                                current_state <= STOP;
                            end
                        end else begin
                            sample_count <= sample_count - 1;
                        end
                    end
                    STOP: begin
                        if (sample_count == 0) begin
                            if (rx_sync) begin
                                valid <= 1'b1;
                            end
                            current_state <= IDLE;
                        end else begin
                            sample_count <= sample_count - 1;
                        end
                    end
                    default: begin
                        current_state <= IDLE;
                    end
                endcase
            end
        end
    end

endmodule
