///////////////////////////////////////////////////////////
// This testbench verifies the functionallity of cla_16bit
// and its normal operation 
// Author: Hernan Carranza, Gabirel Ruggie
///////////////////////////////////////////////////////////
module cla_16bit_tb();
  // define test signals
  reg [15:0] A, B;
  reg sub;
  wire [15:0] Sum;
  wire Ovfl;
  
  // instantiate DUT
  cla_16bit iDUT(.Sum,.Ovfl,.A,.B,.sub);
  
  initial begin
	// init test inputs
	A = 16'h0000;
	B = 16'h0000;
	sub = 1'b0;
	#5;
	if( ((A + B) != Sum) || Ovfl) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result");
	  $stop;
	end
	
	// Test 1: add 2 numbers, no overflow
	A = 16'h0020;
	B = 16'h0020;
	#5;
    if( ((A + B) != Sum) || Ovfl) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result");
	  $stop;
	end
	
	// Test 2: subtract 2 numbers, no overflow
	A = 16'h0001;
	B = 16'hFFFC;
	sub = 1'b1;
	#5;
	if( ((A - B) != Sum) || Ovfl) begin
	  #2;
	  $display("ERROR! Sum did not equal expected result");
	  $stop;
	end
	
	// Test 3: add 2 numbers, positive overflow
	A = 16'h7FFF;
	B = 16'h7FFF;
	sub = 1'b0;
	#5;
	if(!Ovfl) begin
	  #2;
	  $display("ERROR! Positive overflow was not detected!");
	  $stop;
	end	
	
	// Test 4: subtract 2 numbers, negative overflow
	A = 16'h8000;
	B = 16'h7000;
	sub = 1'b1;
	#5;
	if(!Ovfl) begin
	  #2;
	  $display("ERROR! Negative overflow was not detected!");
	  $stop;
	end	
	
	$display("End of test");
	$stop;
  
  end

endmodule