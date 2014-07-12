// Ken Eguro
//		Alpha version - 2/11/09
//		Version 1.0 - 1/4/10
//		Version 1.0.1 - 5/7/10
//		Version 1.1 - 8/1/11

`timescale 1ns / 1ps
`default_nettype none

module iobuf16(IO, I, O, T);
	inout 	wire [15:0] IO;
	input 	wire [15:0] I;
	output 	wire [15:0] O;
	input 	wire 			T;
	
	IOBUF IOBUF_B0(.IO(IO[0]), .I(I[0]), .O(O[0]), .T(T));
	IOBUF IOBUF_B1(.IO(IO[1]), .I(I[1]), .O(O[1]), .T(T));
	IOBUF IOBUF_B2(.IO(IO[2]), .I(I[2]), .O(O[2]), .T(T));
	IOBUF IOBUF_B3(.IO(IO[3]), .I(I[3]), .O(O[3]), .T(T));
	IOBUF IOBUF_B4(.IO(IO[4]), .I(I[4]), .O(O[4]), .T(T));
	IOBUF IOBUF_B5(.IO(IO[5]), .I(I[5]), .O(O[5]), .T(T));
	IOBUF IOBUF_B6(.IO(IO[6]), .I(I[6]), .O(O[6]), .T(T));
	IOBUF IOBUF_B7(.IO(IO[7]), .I(I[7]), .O(O[7]), .T(T));
	IOBUF IOBUF_B8(.IO(IO[8]), .I(I[8]), .O(O[8]), .T(T));
	IOBUF IOBUF_B9(.IO(IO[9]), .I(I[9]), .O(O[9]), .T(T));
	IOBUF IOBUF_B10(.IO(IO[10]), .I(I[10]), .O(O[10]), .T(T));
	IOBUF IOBUF_B11(.IO(IO[11]), .I(I[11]), .O(O[11]), .T(T));
	IOBUF IOBUF_B12(.IO(IO[12]), .I(I[12]), .O(O[12]), .T(T));
	IOBUF IOBUF_B13(.IO(IO[13]), .I(I[13]), .O(O[13]), .T(T));
	IOBUF IOBUF_B14(.IO(IO[14]), .I(I[14]), .O(O[14]), .T(T));
	IOBUF IOBUF_B15(.IO(IO[15]), .I(I[15]), .O(O[15]), .T(T));
endmodule
