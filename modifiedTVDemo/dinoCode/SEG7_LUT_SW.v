// Trevor Sribar
// 11/26/2026
// modified version of SEG7_LUET_X
// takes in a switch and displays a little spinning dial if it on, and a dash if it is off
// outputs this number on the 7-seg dispay in decimal

module SEG7_LUT_SW (	clkIn, oSEG, swIn );

input clkIn; // just for when I want to make the on dash around
input	swIn;
output	[6:0]	oSEG;

reg [6:0] nextPosToWrite = 7'b1111110;
reg [24:0] clockTickCounter = 0;

always @(posedge clkIn) begin
    clockTickCounter <= clockTickCounter + 1;
    if (clockTickCounter == 3375000) begin
        clockTickCounter <= 0;
        if (nextPosToWrite == 7'b1011111) begin
            nextPosToWrite <= 7'b1111110;
        end else begin
            nextPosToWrite <= (nextPosToWrite << 1) | 7'b0000001;
        end
    end else
        nextPosToWrite <= nextPosToWrite;
end

assign oSEG = swIn ? 7'b0111111 : nextPosToWrite;

endmodule