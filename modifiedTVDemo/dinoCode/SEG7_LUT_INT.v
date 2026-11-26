// Trevor Sribar
// 11/25/2026
// modified version of SEG7_LUET_X
// takes in a 12 bit number
// outputs this number on the 7-seg dispay in decimal, or - if the number is really big

module SEG7_LUT_INT (	oSEG0,oSEG1,oSEG2,intIn );

input	[11:0]	intIn;
output	[6:0]	oSEG0,oSEG1,oSEG2;

// need a place to store the int number in case we want to do the dash instead
wire [6:0]  interForSwap0, interForSwap1, interForSwap2;

// get the int number for our input
SEG7_LUT	u0	(	interForSwap0,intIn%10 );
SEG7_LUT	u1	(	interForSwap1,intIn/10%10 );
SEG7_LUT	u2	(	interForSwap2,intIn/100%10 );

// make them a dash if the high bit is set
// cuz it takes much less than 2^31 frames (414 hrs) us to loose, we know there are no obs
assign oSEG0 = intIn[11] ? 7'b0111111 : interForSwap0;
assign oSEG1 = intIn[11] ? 7'b0111111 : interForSwap1;
assign oSEG2 = intIn[11] ? 7'b0111111 : interForSwap2;

endmodule