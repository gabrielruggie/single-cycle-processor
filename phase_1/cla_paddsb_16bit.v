///////////////////////////////////////////////////////////
// This module models a 16-bit carry look ahead adder to
// perform four half-byte additions in parallel to realize
// sub-word parallelism in our ALU.
// It takes in 2's comp operands for addition and 
// subtraction. If overflow occurs in any half-byte, 
// the result is saturated to the largest representable num
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module cla_paddsb_16bit(Sum,A,B,sub);
  input [15:0] A, B;	// vectors to perform 4 adds/sub
  input sub;			// 1 = subtract operands
  output [15:0] Sum;	// concatenated vector of 4 operations
  
  // define local signals
  wire [3:0] B_in1, B_in2, B_in3, B_in4;		// B for adders
  wire [3:0] sum1, sum2, sum3, sum4;		// sums of 4 adders
  wire pos_of1, pos_of2, pos_of3, pos_of4;	// positive ovfl flags for adders
  wire neg_of1, neg_of2, neg_of3, neg_of4;	// negative ovfl flags for adders
  
  assign B_in1 = sub ? ~B[3:0] : B[3:0];
  assign B_in2 = sub ? ~B[7:4] : B[7:4];
  assign B_in3 = sub ? ~B[11:8] : B[11:8];
  assign B_in4 = sub ? ~B[15:12] : B[15:12];
  
  // insantiate 4-bit CLAs
  cla_4bit cla1(.Sum(sum1),.P(),.G(),.A(A[3:0]),.B(B_in1),.Cin(sub));
  cla_4bit cla2(.Sum(sum2),.P(),.G(),.A(A[7:4]),.B(B_in2),.Cin(sub));
  cla_4bit cla3(.Sum(sum3),.P(),.G(),.A(A[11:8]),.B(B_in3),.Cin(sub));
  cla_4bit cla4(.Sum(sum4),.P(),.G(),.A(A[15:12]),.B(B_in4),.Cin(sub));
  
  // define overflow and saturation logic
  // Pos ovfl occurs when (-A + -B = +S) or (A + B = -S)
  // check for each adder
  assign pos_of1 = ~sub & ( (A[3] & B[3] & ~sum1[3]) | (~A[3] & ~B[3] & sum1[3]) );
  assign pos_of2 = ~sub & ( (A[7] & B[7] & ~sum2[3]) | (~A[7] & ~B[7] & sum2[3]) );
  assign pos_of3 = ~sub & ( (A[11] & B[11] & ~sum3[3]) | (~A[11] & ~B[11] & sum3[3]) );
  assign pos_of4 = ~sub & ( (A[15] & B[15] & ~sum4[3]) | (~A[15] & ~B[15] & sum4[3]) );
  
  // neg ovfl occurs if (-A - B = S) or if (A - (-B) = -S)
  assign neg_of1 = sub & ( (A[3] & ~B[3] & ~sum1[3]) | (~A[3] & B[3] & sum1[3]) );
  assign neg_of2 = sub & ( (A[7] & ~B[7] & ~sum2[3]) | (~A[7] & B[7] & sum2[3]) );
  assign neg_of3 = sub & ( (A[11] & ~B[11] & ~sum3[3]) | (~A[11] & B[11] & sum3[3]) );
  assign neg_of4 = sub & ( (A[15] & ~B[15] & ~sum4[3]) | (~A[15] & B[15] & sum4[3]) );
  
  assign Sum[3:0] = pos_of1 ? 4'b0111 : (neg_of1 ? 4'b1000 : sum1);
  assign Sum[7:4] = pos_of2 ? 4'b0111 : (neg_of2 ? 4'b1000 : sum2);
  assign Sum[11:8] = pos_of3 ? 4'b0111 : (neg_of3 ? 4'b1000 : sum3);
  assign Sum[15:12] = pos_of4 ? 4'b0111 : (neg_of4 ? 4'b1000 : sum4);
  
endmodule