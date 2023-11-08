module PCUnit (

    input [2:0] flags, condition_codes,
    input [8:0] immediate,	// from current instruction
	input [15:0] rs_data,	// for Branch Register
    input branch,			// from control unit
    input [15:0] PC_in,		// current pc in decode cycle
    output [15:0] PC_out,	// branch_pc to send to fetch stage
    output reg branch_taken

);

	// local module signals
    wire [15:0] sign_ext_imm, branch_register, PC_p_2;
    reg [15:0] branch_pc;
    wire overflow;
	wire [15:0] branch_target;	// final target PC from branch
	
	assign condition_codes = PC_in[11:9];
	
	// get branch regsiter PC from rs output from register file
	assign branch_register = rs_data;

	// calculate branch target pc value
	assign sign_ext_imm = { {7{immediate[8]} } , immediate } << 1;
    cla_16bit CLA0 ( .A(PC_in), .B(16'h0002), .Sum(PC_p_2), .Ovfl(overflow), .sub(1'b0) );
    cla_16bit CLA1 ( .A(PC_p_2), .B(sign_ext_imm), .Sum(branch_target), .Ovfl(overflow), .sub(1'b0) ); 
	
	// evaluate if branch is taken based on the current flags and condition codes
    always @(*) begin
        case (condition_codes)  
            3'b000 : branch_taken = flags[1] ? 1'b0 : 1'b1;
            3'b001 : branch_taken = flags[1] ? 1'b1 : 1'b0;
            3'b010 : branch_taken = (flags[2] & flags[1]) ? 1'b0 : 1'b1;
            3'b011 : branch_taken = flags[2] ? 1'b1 : 1'b0;
            3'b100 : branch_taken = (flags[1] | (~flags[1] & ~flags[2])) ? 1'b1 : 1'b0;
            3'b101 : branch_taken = (flags[1] | flags[2]) ? 1'b1 : 1'b0;
            3'b110 : branch_taken = flags[0] ? 1'b1 : 1'b0;
           default : branch_taken = 1'b1;
        endcase
    end

	// if BR instruction, take branch reg, otherwise take calculated branch target
    assign PC_out = branch ? branch_register : branch_target;

endmodule