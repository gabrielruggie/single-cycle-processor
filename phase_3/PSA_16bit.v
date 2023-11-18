///////////////////////////////////////////////////////////
// This module performs four nibble signed  integer 
// additions in parallel to create a 16-bit vector. 
// Any overflow in the addition calculation sets OF error.
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module PSA_16bit(Sum,Error,A,B);
  input [15:0] A,B;		// Input data values
  output [15:0] Sum;	// Sum of additions
  output Error;			// Overflow flag
  
  // Declare internal signals
  wire [3:0] Ovfl;	// overflow detection vector
  
  // Instantiate four 4-bit RCA's with sub tied to logic 0
  // concatenation of Sum is performed automatically
  addsub_4bit a_15_12(.Sum(Sum[15:12]),.Ovfl(Ovfl[3]),.A(A[15:12]),.B(B[15:12]),.sub(1'b0));
  addsub_4bit a_11_8(.Sum(Sum[11:8]),.Ovfl(Ovfl[2]),.A(A[11:8]),.B(B[11:8]),.sub(1'b0));
  addsub_4bit a_7_4(.Sum(Sum[7:4]),.Ovfl(Ovfl[1]),.A(A[7:4]),.B(B[7:4]),.sub(1'b0));
  addsub_4bit a_3_0(.Sum(Sum[3:0]),.Ovfl(Ovfl[0]),.A(A[3:0]),.B(B[3:0]),.sub(1'b0));
  
  // OR reduce overflow vector to detect any overflow
  assign Error = |Ovfl;

endmodule