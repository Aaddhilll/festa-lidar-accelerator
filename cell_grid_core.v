// ============================================================
// Module: cell_grid_core
// Project: ASIC Hardware Accelerator for LiDAR Ground Segmentation
// Description:
//   BRAM-based grid storage for LiDAR height values.
//   Supports simultaneous read and write (dual-port behaviour).
//   Full grid reset on rst.
// ============================================================

module cell_grid_core #(
    parameter GRID_SIZE  = 4096,
    parameter DATA_WIDTH = 16
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   write_enable,
    input  wire [11:0]            write_addr,
    input  wire [DATA_WIDTH-1:0]  write_data,
    input  wire [11:0]            read_addr,
    output reg  [DATA_WIDTH-1:0]  read_data
);

    reg [DATA_WIDTH-1:0] grid_memory [0:GRID_SIZE-1];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < GRID_SIZE; i = i + 1)
                grid_memory[i] <= 0;
        end
        else begin
            if (write_enable)
                grid_memory[write_addr] <= write_data;

            read_data <= grid_memory[read_addr];
        end
    end

endmodule
