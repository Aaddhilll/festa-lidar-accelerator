// ============================================================
// Module: cell_index_calculator
// Project: ASIC Hardware Accelerator for LiDAR Ground Segmentation
// Description:
//   Converts X,Y coordinates into a grid memory address.
//   Points outside grid boundary are flagged invalid.
// ============================================================

module cell_index_calculator #(
    parameter GRID_WIDTH  = 64,
    parameter GRID_HEIGHT = 64,
    parameter CELL_SIZE   = 1
)(
    input  wire signed [15:0] x_coord,
    input  wire signed [15:0] y_coord,
    output reg  [15:0]        cell_index,
    output reg                valid
);

    integer x_cell;
    integer y_cell;

    always @(*) begin
        x_cell = x_coord / CELL_SIZE;
        y_cell = y_coord / CELL_SIZE;

        if ((x_cell >= 0) && (x_cell < GRID_WIDTH) &&
            (y_cell >= 0) && (y_cell < GRID_HEIGHT)) begin

            cell_index = (y_cell * GRID_WIDTH) + x_cell;
            valid      = 1'b1;
        end
        else begin
            cell_index = 16'd0;
            valid      = 1'b0;
        end
    end

endmodule
