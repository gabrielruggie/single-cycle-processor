///////////////////////////////////////////////////////////
// This module defines a 4-bit ALU possible of performing
// ADD, SUB, NAND, and XOR. It instantiates an instance
// of addsub_4bit.v to perform ADD and SUB.
// Author: Hernan Carranza
///////////////////////////////////////////////////////////
module ALU(ALU_out, Error, ALU_In1, ALU_In2, Opcode);
  input [1:0] Opcode;			// determines operation
  input [3:0] ALU_In1, ALU_In2; // Inputs to op on
  output reg [3:0] ALU_out;		// Result of op
  output Error;					// indicates overflow
  
  // define params for opcode code legibility
  parameter ADD = 2'b00;
  parameter SUB = 2'b01;
  parameter NAND = 2'b10;
  parameter XOR = 2'b11;
  
  // define local module signals
  wire [3:0] Sum;	// result of add/sub
  
  // instantiate 4-bit RCA for add/sub
  addsub_4bit RCA(.A(ALU_In1),.B(ALU_In2),.sub(Opcode[0]),.Sum,.Ovfl(Error));
  
  // case selection depending on opcode
  always @* begin
	case (Opcode)
	    ADD : ALU_out = Sum;
	    SUB : ALU_out = Sum;
	   NAND : ALU_out = ~(ALU_In1 & ALU_In2);
	    XOR : ALU_out = ALU_In1 ^ ALU_In2;
	default : ALU_out = Sum;
	endcase
  end

endmodule