///////////////////////////////////////////////////////////
// This module models a 1-bit wide Full Adder
// with a carry in bit and a sum bit.
// It determines if it will carry or propogate for a CLA
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module full_adder_1bit(S,P,G,A,B,Cin);
  input A;
  input B;
  input Cin;	// Carry in bit
  output S;		// Sum of addition
  output P;	  // propogate bit
  output G;   // generate bit
  
  // Sum is XOR of all inputs
  assign S = A ^ B ^ Cin;
  
  // propagate bit is one if A or B are one
  assign P = A | B;
  
  // generate bit is one if A and B are one
  assign G = A & B;

endmodule