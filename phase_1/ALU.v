///////////////////////////////////////////////////////////
// This module is the top-level file for our WISC-F23 
// Single Cycle Processor. It performs several logic 
// instructions: ADD, PADDSB, SUB, XOR, SLL, SRA, ROR, RED
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module ALU(ALU_out, Error, ALU_In1, ALU_In2, Opcode);
  input [2:0] Opcode;			       // 3-bit opcode
  input [15:0] ALU_In1, ALU_In2; // Inputs to operate on
  output reg [15:0] ALU_out;		 // Result of op
  output Error;					         // indicates overflow
  
  // define params for opcode code legibility
  parameter ADD = 3'b000;
  parameter SUB = 3'b001;
  parameter XOR = 3'b010;
  parameter RED = 3'b011;
  parameter SLL = 3'b100;
  parameter SRA = 3'b101;
  parameter ROR = 3'b110;
  parameter PADDSB = 3'b111;

  // define local module signals
  
  // instantiate needed modules
  
  // case selection depending on opcode
  always @* begin
	case (Opcode)
	    ADD : ALU_out = Sum;
	    SUB : ALU_out = Sum;
	    XOR : ALU_out = ALU_In1 ^ ALU_In2;
      RED : ;
      SLL : ;
      SRA : ;
      ROR : ;
      PADDSB : ;
	default : ALU_out = Sum;
	endcase
  end

endmodule