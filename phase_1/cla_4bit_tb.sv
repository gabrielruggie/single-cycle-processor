///////////////////////////////////////////////////////////
// This module verifies the correct operation of a 4-bit
// carry look-ahead adder
// Author: Hernan Carranza, Gabriel Ruggie
///////////////////////////////////////////////////////////
module cla_4bit_tb();
  // define test signals
  reg [3:0] A, B;
  reg Cin;
  wire [3:0] Sum;
  wire P,G;
  
  // instantiate DUT
  cla_4bit iDUT(.Sum,.P,.G,.A,.B,.Cin);
  
  initial begin
	// init test inputs
	Cin = 0;
	A = 4'b0000;
	B = 4'b0000;
	#5;
	// Generate random inputs 
	// test 1: add 2 nums, no generate or propogate
	// check result if no overflow has occured
	if ( ((A + B) != Sum) || (P || G) ) begin
	  #2;
	  $display("Error! Sum was not expected result!");
	  $stop;
	end
	
	// test 2: add 2 nums and generate a bit
	A = 4'b1000;
	B = 4'b1000;
	#5;
	if (!G) begin
	  #2;
	  $display("Error! Did not generate a bit!");
	  $stop;
	end
	
	// test 3: add 2 nums and propagate a bit through every adder
	A = 4'b0001;
	B = 4'b1111;
	#5;
	if (!P) begin
	  #2;
	  $display("Error! Did not propogate a bit thorugh every adder!");
	  $stop;
	end
	
	// test 4: normal result
	A = 4'b0010;
	B = 4'b0010;
	#5;
	if ((A + B) != 4) begin
	  #2;
	  $display("Error! Sum did not equal expected result!");
	  $stop;
	end
	$display("End of test");
	$stop;
  end
  

endmodule