////////////////////////////////////////////////////////////
// This verilog file models a 4-bit ripple carry 
// adder and subtractor with an overflow flag output
// to indicate when overflow has occured.
// Inputs assumed 2's comp integers
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module addsub_4bit(Sum,Ovfl,A,B,sub);
  // Module signals
  input [3:0] A;	// 4 bit input A
  input [3:0] B;	// 4 bit input B
  input sub;		// When high, perform A-B, otherwise perform A + B
  output [3:0] Sum; // 4 bit sum of operation
  output Ovfl;		// When high, indicates op has overflowed.

  // Declare internal signals
  wire Cout_0, Cout_1, Cout_2, Cout_3;	// cout bits for bits 0-3.
  wire [3:0] B_in;				// input B that may be complemented
  wire pos_ovfl, neg_ovfl;		// flags for overflow depending on op
  
  // Compute 2's comp of B if subtracting
  assign B_in = sub ? ~B : B;

  // Instantiate full adders
  full_adder_1bit FA0(.A(A[0]),.B(B_in[0]),.Cin(sub),.Cout(Cout_0),.S(Sum[0]));
  full_adder_1bit FA1(.A(A[1]),.B(B_in[1]),.Cin(Cout_0),.Cout(Cout_1),.S(Sum[1]));
  full_adder_1bit FA2(.A(A[2]),.B(B_in[2]),.Cin(Cout_1),.Cout(Cout_2),.S(Sum[2]));
  full_adder_1bit FA3(.A(A[3]),.B(B_in[3]),.Cin(Cout_2),.Cout(Cout_3),.S(Sum[3]));
  
  // Addition overflow check by XORing MSB Cin bit and Cout bit
  assign pos_ovfl = Cout_2 ^ Cout_3;
  
  // Subtraction overflow check by sign checking the sum with the inputs
  // If A - (-B) = -S or if -A - B = S, overflow has occured
  assign neg_ovfl = (sub) & ((Sum[3]&(~A&B)) | (~Sum[3]&(~B&A)));
  
  assign Ovfl = pos_ovfl | neg_ovfl;

endmodule