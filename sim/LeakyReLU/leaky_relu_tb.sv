program leaky_relu_tb #(
	parameter A = 2
    ) (
	output logic [3:0] in,
	input  logic [3:0] result
    );

    task automatic check(
        input logic [3:0] input_val,
        input logic [3:0] expected
    );
        begin
            in = input_val;
            #1; // allow combinational settle

            if (result !== expected)
                $error("FAIL: in=%0d expected=%0d got=%0d",
                        input_val, expected, result);
            else
                $display("PASS: in=%0d result=%0d",
                         input_val, result);
        end
    endtask

    initial begin
        // Positive values → pass-through
	for (int i=0; i < 8; i++) begin
	    if (
	end
        check(4'd1, 4'd1);
        check(4'd3, 4'd3);
        check(4'd7, 4'd7);

        // Zero (note: your design treats 0 as "else")
        check(4'd0, 4'd0);

        // Negative values (4-bit signed)
        check(4'b1111, 4'b1111 >>> 2); // -1 >>> 2 = -1
        check(4'b1000, 4'b1000 >>> 2); // -8 >>> 2 = -2

        $display("All tests completed");
        $finish;
    end
endprogram
