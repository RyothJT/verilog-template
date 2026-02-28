module rle_compressor (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] data_in,
    input  logic       valid_in,
    output logic [7:0] data_out,
    output logic [7:0] count_out,
    output logic       valid_out
);

    logic [7:0] last_byte;
    logic [7:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 8'd0;
            valid_out <= 1'b0;
            last_byte <= 8'd0;
        end else if (valid_in) begin
            if (data_in == last_byte && counter < 8'hFF) begin
                counter   <= counter + 1;
                valid_out <= 1'b0;
            end else begin
                data_out  <= last_byte;
                count_out <= counter;
                valid_out <= (counter > 0);

                last_byte <= data_in;
                counter   <= 8'd1;
            end
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule
