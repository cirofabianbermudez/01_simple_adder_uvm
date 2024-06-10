module adder #(
  parameter Width = 8
)(
  input  logic                    clk,
  input  logic                    rst,
  input  logic signed [Width-1:0] A,
  input  logic signed [Width-1:0] B,
  output logic signed [Width-1:0] C
);

  always @(posedge clk) begin
    if (rst) begin
      C <= '0;
    end else begin
      C <= A + B;
    end
  end

endmodule
