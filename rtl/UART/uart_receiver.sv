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

    // Use explicit widths for synthesis (integers can cause 32-bit inferences)
    localparam int BIT_CNT_W = $clog2(UART_BITS_TRANSFERED) + 1;
    // Need extra bits for initial count of 3*OVERSAMPLE/2 - 2 when entering DATA state
    localparam int SAMPLE_CNT_W = $clog2(3*OVERSAMPLE/2) + 1;

    logic [BIT_CNT_W-1:0] received_bit;
    logic [SAMPLE_CNT_W-1:0] sample_count;

    // Synchronize async RX line to internal clock to reduce metastability/glitches.
    logic rx_meta, rx_sync, rx_sync_d;
    logic rx_falling_edge;  // Latched falling edge detector

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
            rx_sync_d <= 1'b1;
            rx_falling_edge <= 1'b0;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
            rx_sync_d <= rx_sync;
            // Detect falling edge at full clock rate, latch until cleared by state machine
            if (rx_sync_d && ~rx_sync)
                rx_falling_edge <= 1'b1;
            else if (baud_tick && current_state == IDLE && rx_falling_edge)
                rx_falling_edge <= 1'b0;  // Clear when consumed
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
                        // Use latched falling edge (detected at full clock rate)
                        if (rx_falling_edge) begin
                            sample_count <= OVERSAMPLE / 2; // sample in the middle of start bit
                            current_state <= START;
                        end
                    end
                    START: begin
                        if (sample_count == 0) begin
                            if (~rx_sync) begin
                                received_bit <= 0;
                                // Wait 1.5 bit periods from start bit center to data bit 0 center
                                // This aligns sampling with the middle of each data bit
                                sample_count <= OVERSAMPLE + OVERSAMPLE/2 - 2;
                                current_state <= DATA;
                            end else begin
                                current_state <= IDLE; // false start
                            end
                        end else begin
                            sample_count <= sample_count - 1;
                        end
                    end
                    DATA: begin
                        // Sample slightly before center to compensate for baud rate being ~0.5% fast
                        if (sample_count == OVERSAMPLE/2 + 1) begin
                            result[received_bit] <= rx_sync;
                        end
                        if (sample_count == 0) begin
                            received_bit <= received_bit + 1;
                            sample_count <= OVERSAMPLE - 1;
                            if (received_bit == UART_BITS_TRANSFERED-1) begin
                                current_state <= STOP;
                            end
                        end else begin
                            sample_count <= sample_count - 1;
                        end
                    end
                    STOP: begin
                        // Single sample at stop bit center
                        if (sample_count == 0) begin
                            valid <= 1'b1;  // Always accept if we got this far
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
