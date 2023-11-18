///////////////////////////////////////////////////////////
// This module models a 16-bit carry look ahead adder for
// our ALU. It takes in 2's comp operands for addition and 
// subtraction. If overflow occurs, a flag is set and the
// result is saturated to the largest representable num.
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module cla_16bit(Sum,Ovfl,A,B,sub);
  input [15:0] A, B;	// vectors to add
  input sub;			// determines subtraction
  output [15:0] Sum;	// sum of operation
  output Ovfl;			// 1 = overflow, will saturate sum
  
  // define local signals
  wire [15:0] B_in;			// B for adders, 2's comp B if subtracting
  wire [15:0] sum;			// sum of adders before potential saturation
  wire c4,c8,c12,c15;		// carry bits of 4-bit CLA's
  wire g_b1,g_b2,g_b3,g_b4; // generate bits from 4-bit CLA's
  wire p_b1,p_b2,p_b3,p_b4; // propagate bits from 4-bit CLA's
  wire pos_ovfl, neg_ovfl;	// flags for overflow depending on op
  
  assign B_in = sub ? ~B : B;
  
  // instantiate CLA's
  cla_4bit b1(.Sum(sum[3:0]),.P(p_b1),.G(g_b1),.A(A[3:0]),.B(B_in[3:0]),.Cin(sub));
  cla_4bit b2(.Sum(sum[7:4]),.P(p_b2),.G(g_b2),.A(A[7:4]),.B(B_in[7:4]),.Cin(c4));
  cla_4bit b3(.Sum(sum[11:8]),.P(p_b3),.G(g_b3),.A(A[11:8]),.B(B_in[11:8]),.Cin(c8));
  cla_4bit b4(.Sum(sum[15:12]),.P(p_b4),.G(g_b4),.A(A[15:12]),.B(B_in[15:12]),.Cin(c12));
  
  // define carry look-ahead logic
  // carry generated when MSB of previous block generated a carry
  // or it propagates a bit and carry in was one
  assign c4 = g_b1 | (p_b1 & sub);
  assign c8 = g_b2 | (p_b2 & c4);
  assign c12 = g_b3 | (p_b3 & c8);
  assign c15 = g_b4 | (p_b4 & c12);
  
  // define overflow and saturation logic
  // Pos ovfl occurs when (-A + -B = +S) or (A + B = -S)
  assign pos_ovfl = ~sub & ( (A[15] & B[15] & ~sum[15]) | (~A[15] & ~B[15] & sum[15]) );
  
  // neg ovfl occurs if (-A - B = S) or if (A - (-B) = -S)
  assign neg_ovfl = sub & ( (A[15] & ~B[15] & ~sum[15]) | (~A[15] & B[15] & sum[15]) );
  
  assign Ovfl = pos_ovfl | neg_ovfl;
  
  assign Sum = Ovfl ? (pos_ovfl ? 16'h7FFF : (neg_ovfl ? 16'h8000 : sum)) : sum;
  
  
endmodule