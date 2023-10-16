///////////////////////////////////////////////////////////
// This module is the top-level file for our WISC-F23 
// Single Cycle Processor. It performs several logic 
// instructions: ADD, PADDSB, SUB, XOR, SLL, SRA, ROR, RED
// Authors: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module ALU(
  
  input [3:0] Opcode,
  input [15:0] ALU_In1, ALU_In2,
  output [2:0] flags, enable,
  output [15:0] ALU_out 

);

  wire [15:0] sum, shft_out, difference, paddsb, red;
  wire ovflow0, ovflow1;

  reg [15:0] alu_out_reg;
  reg [2:0] enable_reg;
  reg [2:0] flags_reg;

  // define local module signals
  cla_16bit ADDER ( .A(ALU_In1), .B(ALU_In2), .Sum(sum), .Ovfl(ovflow0), .sub(1'b0) );
  cla_16bit SUBER ( .A(ALU_In1), .B(ALU_In2), .Sum(difference), .Ovfl(ovflow1), .sub(1'b1) );
  red_16bit RED   (.Sum(red),.A(ALU_In1),.B(ALU_In2));
  cla_paddsb_16bit PDDSB ( .A(ALU_In1), .B(ALU_In2), .Sum(paddsb), .sub(1'b0) );
  shifter Shift(.Shift_Out(shft_out),.Shift_In(ALU_In1),.Shift_Val(ALU_In2[3:0]),.Mode(Opcode[1:0]));

  // case selection depending on opcode
  always @(*) begin
    
    case (Opcode) 

      4'h0: begin
            alu_out_reg = sum;
            enable_reg = 3'b111;

            flags_reg[0] = ovflow0 ? 1'b1 : 1'b0;
            flags_reg[2] = sum[15] ? 1'b1 : 1'b0;
      end
      4'h1: begin
            alu_out_reg = difference;
            enable_reg = 3'b111;

            flags_reg[0] = ovflow1 ? 1'b1 : 1'b0;
            flags_reg[2] = difference[15] ? 1'b1 : 1'b0;
      end
      4'h2: begin
            alu_out_reg = ALU_In1 ^ ALU_In2;
            enable_reg = 3'b010;
      end
      4'h3: begin
            alu_out_reg = red;
            enable_reg = 3'b010;
      end
      4'h4: begin
            alu_out_reg = shft_out;
            enable_reg = 3'b010;
      end
      4'h5: begin
            alu_out_reg = shft_out;
            enable_reg = 3'b010;
      end
      4'h6: begin
            alu_out_reg = shft_out;
            enable_reg = 3'b010;
      end
      4'h7: begin
            alu_out_reg = paddsb;
            enable_reg = 3'b010;
      end
      4'h8: begin
            alu_out_reg = sum;
            enable_reg = 3'b000;
      end
      4'h9: begin
            alu_out_reg = sum;
            enable_reg = 3'b000;
      end
      default: begin
            alu_out_reg = ALU_In1 | ALU_In2;
            enable_reg = 3'b000;
      end
      
    endcase

  end

  assign enable = enable_reg;
  assign ALU_out = alu_out_reg;
  assign flags = (alu_out_reg == 16'h0000) ? (flags_reg | 3'b010) : flags_reg; // Assign bit 1 if output is equal to zero

endmodule
