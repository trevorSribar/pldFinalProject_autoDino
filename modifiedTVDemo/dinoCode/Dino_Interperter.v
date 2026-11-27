// Trevor Sribar
// 11/25/2026
// runs the interperation for playing the dinosaur game
// takes in pixel data
// outputs red pixels for perceived threats
// outputs a frame count for when the next collision would happen
// outputs a command for up and down
`define DINO_NO_OBS_TIME 12'b100000000000
`define DINO_EARLY_X_RESET_VAL 500
`define DINO_LOCATION_X 240

module Dino_Interperter(
    input clock,
    input [10:0]columnX,
    input [10:0]rowY,
    input [7:0]geyscalePixel,
    input newFrame,
    // might need to add a valid to count stuff, but starting with an ingore regoin should deal w/ that

    output upCommand,
    output downCommand,
    output reg [11:0] timeTillCollision,
    output setRedFlag
);

//
// registers
//

// the closest obstacle
reg [8:0] earliestX = `DINO_EARLY_X_RESET_VAL;
reg [8:0] oldEarliestX = `DINO_EARLY_X_RESET_VAL;
reg [7:0] posObjY = 0;

// how fast that obstacle is moving
reg [8:0] movementPerFrame = 1;
reg [7:0] framesPerMove = 0;
reg [7:0] oldFramesPerMove = 0;

// X 209 to 450
// Y 240 to 284

// wires
wire inLayer = columnX > 250 && columnX < 450 && rowY > 240 && rowY < 284;
//wire tempBounds = (columnX == 209 || columnX == 450 || rowY == 240 || rowY == 284);

//
// logic
//

// reset the loop variables when we get a new frame & get a count for the number of frames we needed to wait to see earleist X move
always @(posedge newFrame) begin

    // if the earliest X is the reset value, then there are no obstacles
    if(earliestX == `DINO_EARLY_X_RESET_VAL) begin
        timeTillCollision = `DINO_NO_OBS_TIME;
    end else begin  // there is an obstacle
        // if it is the same, then it hasn't moved
        if (earliestX == oldEarliestX) begin
            framesPerMove <= framesPerMove+1;
        // if we are at the same obstacle then we see how much it moved
        end else if (earliestX<oldEarliestX) begin
            movementPerFrame = oldEarliestX - earliestX;
            oldFramesPerMove = framesPerMove;
            framesPerMove <= 0;
        end else begin // we are at a new obstacle
            framesPerMove <= 0;
        end

        // find out when we shoud have a collision
        timeTillCollision = (earliestX - `DINO_LOCATION_X) * oldFramesPerMove / movementPerFrame;
    end
    
    // Store "previous loop" variables
    oldEarliestX = earliestX;

    // reset loop variables
    earliestX = `DINO_EARLY_X_RESET_VAL;
end

// the actual logic
always @(posedge clock) begin
    // if we're in the barrier and are a dark pixel
    if(inLayer && !geyscalePixel[7]) begin
        if(earliestX>columnX) begin
            movementPerFrame = earliestX-columnX;
            earliestX = columnX;
        end
    end
end

// debug assignment
assign setRedFlag = 1'b0;
assign upCommand = 1'b0;
assign downCommand = 1'b0;

endmodule