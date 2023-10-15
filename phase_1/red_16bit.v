///////////////////////////////////////////////////////////
// This module performs the RED instruction in our ALU.
// It reduces 4-byte sized operands and adds (a+c) and (b+d)
// and sign extends the result to
// fill the size of the original vectors.
// A = aaaaaaaa_bbbbbbbb and B = cccccccc_dddddddd
// First perform (a+b) and (c+d) then a second level of 
// addition, performing (sum_ab + sum_cd)
// Author: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module red_16bit(Sum,A,B);
  input [15:0] A, B;		// vectors to reduce
  output [15:0] Sum;		
  
  // define internal signals
  wire [8:0] sum_ab, sum_cd;							// sum of first level
  wire G_ab_low, G_ab_high, G_cd_low, G_cd_high;		// G bits of first level of adders
  wire P_ab_low, P_cd_low;								// P bits for first level of adders
  wire G_final_1, G_final_2, G_final_3;					// G bits of second level of adders
  wire P_final_1, P_final_2;							// P bits of second level of adders
  wire pos_ovfl_ab, pos_ovfl_cd, pos_ovfl_final;		// of flags for adders
  wire neg_ovfl_ab, neg_ovfl_cd, neg_ovfl_final;						
  
  // instantiate 4-bit CLA's 
  // first level of tree: perform (a+b) and (c+d) as 9-bit results
  cla_4bit ab_lower(.Sum(sum_ab[3:0]),.P(P_ab_low),.G(G_ab_low),.A(A[11:8]),.B(B[3:0]),.Cin(1'b0));
  cla_4bit ab_upper(.Sum(sum_ab[7:4]),.P(),.G(G_ab_high),.A(A[15:12]),.B(B[7:4]),.Cin(G_ab_low));
  cla_4bit cd_lower(.Sum(sum_cd[3:0]),.P(P_cd_low),.G(G_cd_low),.A(B[11:8]),.B(B[3:0]),.Cin(sub));
  cla_4bit cd_upper(.Sum(sum_cd[7:4]),.P(),.G(G_cd_high),.A(B[15:12]),.B(B[7:4]),.Cin(G_cd_low));
  // second level of tree: perform (sum_ab + sum_cd) as 13 bit result
  cla_4bit cla1(.Sum(Sum[3:0]),.P(P_final_1),.G(G_final_1),.A(sum_ab[3:0]),.B(sum_cd[3:0]),.Cin(sub));
  cla_4bit cla2(.Sum(Sum[7:4]),.P(P_final_2),.G(G_final_2),.A(sum_ab[7:4]),.B(sum_cd[7:4]),.Cin(G_final_1));
  cla_4bit cla3(.Sum(Sum[11:8]),.P(),.G(G_final_3),.A({4{sum_ab[8]}}),.B({4{sum_cd[8]}}),.Cin(G_final_2));
  
  // define logic to set MSB correctly
  // Pos ovfl occurs when (-A + -B = +S) or (A + B = -S)
  assign pos_ovfl_ab = ~sub & ( (A[15] & A[7] & ~sum_ab[7]) | (~A[15] & ~A[7] & sum_ab[7]) );
  assign pos_ovfl_cd = ~sub & ( (B[15] & B[7] & ~sum_cd[7]) | (~B[15] & ~B[7] & sum_cd[7]) );
  assign pos_ovfl_final = ~sub & ( (sum_ab[8] & ~sum_cd[8] & ~Sum[11]) | (~sum_ab[8] & ~sum_cd[8] & Sum[11]) );
  
  // neg ovfl occurs if (-A - B = S) or if (A - (-B) = -S)
  assign neg_ovfl_ab = sub & ( (A[15] & ~A[7] & ~sum_ab[7]) | (~A[15] & A[7] & sum_ab[7]) );
  assign neg_ovfl_cd = sub & ( (B[15] & ~B[7] & ~sum_cd[7]) | (~B[15] & B[7] & sum_cd[7]) );
  assign neg_ovfl_final = sub & ( (sum_ab[8] & ~sum_cd[8] & ~Sum[11]) | (~sum_ab[8] & sum_cd[8] & Sum[11]) );  
  
  // calculate correct value of sum_ab and sum_cd
  // If overflow detected, concatenate with the generate bit of the adder.
  // Ohterwise, sign extend result.
  assign sum_ab = (pos_ovfl_ab | neg_ovfl_ab) ? {G_ab_high,sum_ab[7:0]} : {sum_ab[7],sum_ab[7:1]};
  assign sum_cd = (pos_ovfl_cd | neg_ovfl_cd) ? {G_cd_high,sum_cd[7:0]} : {sum_cd[7],sum_cd[7:0]};
  assign Sum = (pos_ovfl_final | neg_ovfl_final) ? {{4{G_final_3}},Sum[11:0]} : {{4{Sum[11]}},Sum[11:0]};

  
  
  

endmodule