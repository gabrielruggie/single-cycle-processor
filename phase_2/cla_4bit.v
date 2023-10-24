///////////////////////////////////////////////////////////
// This module models a 4-bit carry look ahead adder for
// our ALU. It takes in 2's comp integers and outputs a 
// Generate bit and a propagate bit for this cla block
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module cla_4bit(Sum,P,G,A,B,Cin);
  input [3:0] A, B; // vectors to add
  input Cin;        // Carry in bit
  output [3:0] Sum; // sum of operation
  output P, G;		// Propagate and Generate flag for this block

  // define local signals
  wire c1,c2,c3;          		// carry bits
  wire g3,g2,g1,g0,p3,p2,p1,p0; // generate & propogate bits for cla

  // instantiate adders
  full_adder_1bit s0(.S(Sum[0]),.P(p0),.G(g0),.A(A[0]),.B(B[0]),.Cin(Cin));
  full_adder_1bit s1(.S(Sum[1]),.P(p1),.G(g1),.A(A[1]),.B(B[1]),.Cin(c1));
  full_adder_1bit s2(.S(Sum[2]),.P(p2),.G(g2),.A(A[2]),.B(B[2]),.Cin(c2));
  full_adder_1bit s3(.S(Sum[3]),.P(p3),.G(g3),.A(A[3]),.B(B[3]),.Cin(c3));
  
  // define carry look-ahead logic
  // A carry is generated when the adder generates a carry, or if a carry 
  // in bit is taken and it propogates a bit
  assign c1 = g0 | (p0 & Cin);
  assign c2 = g1 | (p1 & c1);
  assign c3 = g2 | (p2 & c2);
  
  // Propagate is one when all adders propogate
  assign P = p3 & p2 & p1 & p0;
  
  // generate is one when MSB generates or if a generate is propogated 
  // though the lower bits
  assign G = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0);	
  
endmodule