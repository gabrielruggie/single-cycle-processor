////////////////////////////////////////////////////////////
// This module is responsible for performing 
// Shift Left Logical, Shift Right Arithemtic, and 
// Right Rotation from its 16-bit input vector. 
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module shifter(Shift_Out, Shift_In, Shift_Val, Mode);
  input [15:0] Shift_In;		// vector to shift
  input [3:0] Shift_Val;		// shift amount
  input [1:0] Mode;				// determines type of Shift
  output [15:0] Shift_Out;		// shifted output
  
  // define modes for code clarity
  parameter SLL = 2'b00;
  parameter SRA = 2'b01;
  parameter ROR = 2'b10;
  
  // define internal signals
  reg [15:0] shift_1, shift_2, shift_3, shift_4;	// intermediate shift values
  
  always @(*) begin
	case (Mode)
	  SLL : begin
	    shift_1 = Shift_Val[0] ? {Shift_In[14:0], 1'b0} : Shift_In;
		shift_2 = Shift_Val[1] ? {shift_1[13:0], 2'b00} : shift_1;
		shift_3 = Shift_Val[2] ? {shift_2[11:0], 4'b000} : shift_2;
		shift_4 = Shift_Val[3] ? {shift_3[7:0], 8'b00000000} : shift_3;
	  end
	  SRA : begin
		shift_1 = Shift_Val[0] ? {Shift_In[15], Shift_In[15:1]} : Shift_In;
		shift_2 = Shift_Val[1] ? {{2{shift_1[15]}}, shift_1[15:2]} : shift_1;
		shift_3 = Shift_Val[2] ? {{4{shift_2[15]}}, shift_2[15:4]} : shift_2;
		shift_4 = Shift_Val[3] ? {{8{shift_3[15]}}, shift_3[15:8]} : shift_3;
	  end
	  ROR : begin
		shift_1 = Shift_Val[0] ? {Shift_In[0], Shift_In[15:1]} : Shift_In;
		shift_2 = Shift_Val[1] ? {shift_1[1],shift_1[0],shift_1[15:2]} : shift_1;
		shift_3 = Shift_Val[2] ? {shift_2[3],shift_2[2],shift_2[1],shift_2[0],shift_2[15:4]} : shift_2;
		shift_4 = Shift_Val[3] ? {shift_3[8],shift_3[7],shift_3[6],shift_3[5],shift_3[4],shift_3[3],
									shift_3[2],shift_3[1],shift_3[0],shift_3[15:8]} : shift_3;
	  end
	  // default : no shift, assign intermediates to avoid X's
	  default : begin
		shift_1 = Shift_In;
		shift_2 = Shift_In;
		shift_3 = Shift_In;
	    shift_4 = Shift_In;
	  end
	endcase
  end

  assign Shift_Out = shift_4;

endmodule