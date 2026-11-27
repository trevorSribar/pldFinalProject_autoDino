// Trevor Sribar
// 11/25/2026
// runs the interperation for playing the dinosaur game
// takes in pixel data
// outputs red pixels for perceived threats
// outputs a frame count for when the next collision would happen
// outputs a command for up and down
`define DINO_NO_OBS_TIME 12'b100000000000
`define DINO_EARLY_X_RESET_VAL 500
`define DINO_LOCATION_X 225
`define DINO_MIN_X_LOOK 230
`define DINO_MAX_X_LOOK 450
`define DINO_MIN_Y_LOOK 240
`define DINO_MAX_Y_LOOK 284

module Dino_Interperter(
    input clock,
    input [10:0]columnX,
    input [10:0]rowY,
    input [7:0]geyscalePixel,
    input newFrame,
    input commandSwitch,
    input displayBarrierSwitch,
    // might need to add a valid to count stuff, but starting with an ingore regoin should deal w/ that

    output upCommand,
    output downCommand,
    output reg [11:0] timeTillCollision,
    output reg setRedFlag,
    output setBlueFlag
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

// for seeing if we are in a new frame
reg lastNewFrame = 0;

// X 209 to 450
// Y 240 to 284

// wires
wire inLayer = columnX > `DINO_MIN_X_LOOK
             && columnX < `DINO_MAX_X_LOOK
             && rowY > `DINO_MIN_Y_LOOK
             && rowY < `DINO_MAX_Y_LOOK;

wire pixelPartBounds = (columnX == `DINO_MIN_X_LOOK 
                && rowY >= `DINO_MIN_Y_LOOK && rowY <= `DINO_MAX_Y_LOOK)
            || (columnX == `DINO_MAX_X_LOOK 
                && rowY >= `DINO_MIN_Y_LOOK && rowY <= `DINO_MAX_Y_LOOK)
            || (rowY == `DINO_MIN_Y_LOOK 
                && columnX >= `DINO_MIN_X_LOOK && columnX <= `DINO_MAX_X_LOOK)
            || (rowY == `DINO_MAX_Y_LOOK
                && columnX >= `DINO_MIN_X_LOOK && columnX <= `DINO_MAX_X_LOOK);

assign setBlueFlag = displayBarrierSwitch ? pixelPartBounds : 0;

//
// logic
//
always @(posedge clock) begin
    // check if we are in a new frame, if so reset loop stuff
    if(newFrame && lastNewFrame == 0) begin
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
    // we aren't resetting
    // if we're in the barrier and are a dark pixel
    else if(inLayer && !geyscalePixel[7] && !geyscalePixel[5]) begin
        if(earliestX>columnX) begin
            earliestX = columnX;
            posObjY = rowY;
        end
    end
    if(oldEarliestX != `DINO_EARLY_X_RESET_VAL && oldEarliestX == columnX)
        setRedFlag = 1'b1;
    else
        setRedFlag = 1'b0;
    lastNewFrame <= newFrame;
end

// debug assignment
assign upCommand = 1'b0;
assign downCommand = 1'b0;

endmodule