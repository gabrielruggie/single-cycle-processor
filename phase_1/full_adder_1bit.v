///////////////////////////////////////////////////////////
// This module models a 1-bit wide Full Adder
// with a carry in bit, a sum bit, and a carry out bit.
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module full_adder_1bit(S,Cout,A,B,Cin);
  input A;
  input B;
  input Cin;	// Carry in bit
  output S;		// Sum of addition
  output Cout;	// Carry out bit
  
  // Sum is XOR of all inputs
  assign S = A ^ B ^ Cin;
  
  // Cout generated if 2 or more inputs are 1
  assign Cout = (A&B) | (A&Cin) | (B&Cin);

endmodule