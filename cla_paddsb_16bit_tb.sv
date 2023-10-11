///////////////////////////////////////////////////////////
// This testbench verifies the functionallity of 
// cla_paddsb_16bit and its normal operation.
// Author: Hernan Carranza, Gabirel Ruggie
///////////////////////////////////////////////////////////
module cla_paddsb_16bit_tb();
  reg [15:0] A, B;
  reg sub;
  wire [15:0] Sum;
  
  // instantiate DUT
  cla_paddsb_16bit iDUT(.Sum,.A,.B,.sub);
  
  initial begin
	// init test vectors
	A = 16'h0000;
	B = 16'h0000;
	sub = 1'b0;
	#5;
	if (Sum !== 16'h0000) begin
	  #2;
	  $display("ERROR! Sum did not equal a valid result!");
	  $stop;
	end
	
	// Test 1: addition, no overflow
	A = 16'h2222;
	B = 16'h2222;
	#5;
	if (Sum !== 16'h4444) begin
	  #2;
	  $display("ERROR! Sum did not equal a expected result!");
	  $stop;
	end
	
	// Test 2: addition with overflow
	A = 16'h7070;
	B = 16'h1010;
	#5;
	if (Sum !== 16'h7070) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result!");
	  $stop;
	end
	
	// Test 3: subtration, no overflow
	A = 16'h7777;
	B = 16'h4444;
	sub = 1'b1;
	#5;
	if (Sum !== 16'h3333) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result!");
	  $stop;
	end
	
	// Test 4: subtraction with overflow
	A = 16'h0707;
	B = 16'h0808;
	#5;
	if (Sum !== 16'h0808) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result!");
	  $stop;
	end
	
	$display("End of test");
	$stop;
  end

endmodule