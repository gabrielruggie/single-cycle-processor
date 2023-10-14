///////////////////////////////////////////////////////////
// This module is the top-level file for our WISC-F23 
// Single Cycle Processor. It performs several logic 
// instructions: ADD, PADDSB, SUB, XOR, SLL, SRA, ROR, RED
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module ALU(
  
  input [3:0] Opcode,
  input [15:0] ALU_In1, ALU_In2,
  output [2:0] flags,
  output [2:0] enable,
  output [15:0] ALU_out, 

);

  wire [15:0] sum, shft_out, difference, paddsb, exor, red;
  wire ovflow0, ovflow1;
  
  // define params for opcode code legibility
  parameter ADD = 3'b000;
  parameter SUB = 3'b001;
  parameter XOR = 3'b010;
  parameter RED = 3'b011;
  parameter SLL = 3'b100;
  parameter SRA = 3'b101;
  parameter ROR = 3'b110;
  parameter PADDSB = 3'b111;

  reg [15:0] _alu_out;
  reg [2:0] _flags;
  reg _enable;

  // define local module signals
  cla_16bit ADDER ( .A(ALU_In1), .B(ALU_In2), .Sum(sum), .Ovfl(ovflow0), .sub(1'b0) );
  cla_16bit SUBER ( .A(ALU_In1), .B(ALU_In2), .Sum(difference), .Ovfl(ovflow1), .sub(1'b1) );
  red_16bit RED   (.Sum(red),.A(ALU_In1),.B(ALU_In2));
  cla_paddsb_16bit PDDSB ( .A(ALU_In1), .B(ALU_In2), .Sum(paddsb), .sub(1'b0) );
  shifter Shift(.Shift_Out(shft_out),.Shift_In(ALU_In1),.Shift_Val([ALU_In2[3:0]]),.Mode(opcode[1:0]));

  // case selection depending on opcode
  always @(*) begin
    
    case (Opcode) 

      4'h0: begin
            assign _alu_out = sum;
            assign _enable = 3'b111;

            assign _flags[0] = ovflow0 ? 1'b1 : 1'b0;
            assign _flags[2] = sum[15] ? 1'b1 : 1'b0;
      end
      4'h1: begin
            assign _alu_out = difference;
            assign _enable = 3'b111;

            assign _flags[0] = ovflow1 ? 1'b1 : 1'b0;
            assign _flags[2] = difference[15] ? 1'b1 : 1'b0;
      end
      4'h2: begin
            assign _alu_out = exor;
            assign _enable = 3'b010;
      end
      4'h3: begin
            assign _alu_out = red;
            assign _enable = 3'b010;
      end
      4'h4: begin
            assign _alu_out = shft_out;
            assign _enable = 3'b010;
      end
      4'h5: begin
            assign _alu_out = shft_out;
            assign _enable = 3'b010;
      end
      4'h6: begin
            assign _alu_out = shft_out;
            assign _enable = 3'b010;
      end
      4'h7: begin
            assign _alu_out = paddsb;
            assign _enable = 3'b010;
      end
      4'h8: begin
            assign _alu_out = sum;
            assign _enable = 3'b000;
      end
      4'h9: begin
            assign _alu_out = sum;
            assign _enable = 3'b000;
      end
      default: begin
            assign _alu_out = ALU_In1 | ALU_In2;
            assign _enable = 3'b000;
      end
      
    endcase

  end

  assign enable = _enable;
  assign ALU_out = _alu_out;
  assign flags = (_alu_out == 16'h0000) ? (_flags | 3'b010) : _flags; // Assign bit 1 if output is equal to zero

endmodule