///////////////////////////////////////////////////////////
// Single cycle instruction cache that is byte-addressable
// and 2KB (2048 Bytes) in size, 2-way set-associative,
// with cache blocks of 16B each
///////////////////////////////////////////////////////////
module I_Cache (
	
	input clk, 
	input rst,
	input write_en_0,
	input write_en_1,
	input data_wen,
	input tag_wen,
	input [15:0] data_in,	// data to write to cache
	input [7:0]  tag_in_0, 	// tag of block we are looking for
	input [7:0]  tag_in_1,
	input [7:0]  word,		// word to select
	input [63:0] block_en,	// selects which block to read/write
   output [15:0] data_out_0,// data recieved from cache
   output [15:0] data_out_1,
   output [7:0]  tag_out_0,
   output [7:0]  tag_out_1

);
	
	// instantiate 2 data/metadata arrays for way 0 and way 1 to read from cache in one cycle
	DataArray dataArray_0(.clk, .rst, .DataIn(data_in), .Write(write_en_0 && data_wen), .BlockEnable(block_en), .WordEnable(word), .DataOut(data_out_0));
	DataArray dataArray_1(.clk, .rst, .DataIn(data_in), .Write(write_en_1 && data_wen), .BlockEnable(block_en), .WordEnable(word), .DataOut(data_out_1));
	MetaDataArray metaDataArray_0(.clk, .rst, .DataIn(tag_in_0), .Write(write_en_0 && tag_wen), .BlockEnable(block_en), .DataOut(tag_out_0));
	MetaDataArray metaDataArray_1(.clk, .rst, .DataIn(tag_in_1), .Write(write_en_1 && tag_wen), .BlockEnable(block_en), .DataOut(tag_out_1));


endmodule