module adder #(
  parameter Width = 8
)(
  input  logic signed [Width-1:0] A,
  input  logic signed [Width-1:0] B,
  output logic signed [Width-1:0] C
);

  assign C = A + B;

endmodule
