// ============================================================
// Module: ground_segmentation_core
// Project: ASIC Hardware Accelerator for LiDAR Ground Segmentation
// Description:
//   Performs threshold-based ground segmentation.
//   Points with height <= HEIGHT_THRESHOLD are classified as ground.
//   Registered output ensures timing closure.
// ============================================================

module ground_segmentation_core #(
    parameter HEIGHT_THRESHOLD = 16'd50
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] point_height,
    input  wire        point_valid,
    output reg         ground_flag,
    output reg         output_valid
);

    always @(posedge clk) begin
        if (rst) begin
            ground_flag  <= 1'b0;
            output_valid <= 1'b0;
        end
        else begin
            if (point_valid) begin
                ground_flag  <= (point_height <= HEIGHT_THRESHOLD) ? 1'b1 : 1'b0;
                output_valid <= 1'b1;
            end
            else begin
                output_valid <= 1'b0;
            end
        end
    end

endmodule
