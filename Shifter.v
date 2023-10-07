///////////////////////////////////////////////////////////
// This module implements a 16-bit shifter that can perform
// a Shift Left Logical and a Shift Right Arithmetic.
// The 4-bit shift amount is an unsigned binary number
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module Shifter(Shift_Out, Shift_In, Shift_Val, Mode);
  input [15:0] Shift_In;	// Input vector to shift
  input [3:0] Shift_Val;	// Shift amount
  input Mode;				// Logic 0= SLL; Logic 1 = SRA
  output [15:0] Shift_Out;	// Shifted output data

  // Declare internal signals
  // Buses to hold stages of shifting from MUXes for L/A 
  wire [15:0] eight_shft_L,four_shft_L,two_shft_L,one_shft_L;
  wire [15:0] eight_shft_A,four_shft_A,two_shft_A,one_shft_A;
  
  // Implement a barrel shifter as a series of muxes 
  // based on the bits of Shift_Val: 
  // Shift[3] = Shift_In << 8, Shift[2] = << 4...
  assign eight_shft_L = Shift_Val[3] ? Shift_In << 8 : Shift_In;
  assign four_shft_L = Shift_Val[2] ? eight_shft_L << 4 : eight_shft_L;
  assign two_shft_L = Shift_Val[1] ? four_shft_L << 2 : four_shft_L;
  assign one_shft_L = Shift_Val[0] ? two_shft_L << 1 : two_shft_L;
  
  // Implement a barrel shifter that preserves the sign of 
  // the MSB of Shift_In by concatenating and replecating the
  // MSB by the shift amount
  assign eight_shft_A = Shift_Val[3] ? {{8{Shift_In[15]}},Shift_In[15:8]}:Shift_In;
  assign four_shft_A = Shift_Val[2] ? {{4{eight_shft_A[15]}},eight_shft_A[15:4]}:eight_shft_A;
  assign two_shft_A = Shift_Val[1] ? {{2{four_shft_A[15]}},four_shft_A[15:2]}:four_shft_A;
  assign one_shft_A = Shift_Val[0] ? {two_shft_A[15],two_shft_A[15:1]}:two_shft_A;
  
  assign Shift_Out = Mode ? one_shft_A : one_shft_L;

endmodule