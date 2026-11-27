// Trevor Sribar
// 11/25/2026
// runs the interperation for playing the dinosaur game
// takes in pixel data
// outputs red pixels for perceived threats
// outputs a frame count for when the next collision would happen
// outputs a command for up and down

module Dino_Interperter(
    input clock,
    input [10:0]columnX,
    input [10:0]rowY,
    input [7:0]geyscalePixel,
    // might need to add a valid to count stuff, but starting with an ingore regoin should deal w/ that

    output upCommand,
    output downCommand,
    output [11:0] timeTillCollision,
    output setRedFlag
);

wire inLayer = columnX > 240 && columnX < 480 && rowY > 240 && rowY < 480;
wire tempBounds = (columnX == 209 || columnX == 450 || rowY == 240 || rowY == 284);

// debug findout where exact keepout
assign setRedFlag = tempBounds;
assign upCommand = 1'b0;
assign downCommand = 1'b0;
assign timeTillCollision = 12'b100000000000;

endmodule