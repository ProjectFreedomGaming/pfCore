// SPDX-FileCopyrightText: 2023-present pfCore contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

`default_nettype none

// video generation
//
// ~12,288,000 hz pixel clock
// we want our video mode of 320x240 @ 60hz, this results in 204800 clocks per frame
// we need to add hblank and vblank times to this, so there will be a nondisplay area. 
// it can be thought of as a border around the visible area.
// to make numbers simple, we can have 400 total clocks per line, and 320 visible.
// dividing 204800 by 400 results in 512 total lines per frame, and 240 visible.
// this pixel clock is fairly high for the relatively low resolution, but that's fine.
// PLL output has a minimum output frequency anyway.

module pf_flip (input   wire        reset_n,
                input   wire logic  clk_core_12288,
                output  wire [23:0] video_rgb,
                output  wire        video_de,
                output  wire        video_skip,
                output  wire        video_vs,
                output  wire        video_hs);

assign video_rgb = vidout_rgb;
assign video_de = vidout_de;
assign video_skip = vidout_skip;
assign video_vs = vidout_vs;
assign video_hs = vidout_hs;

    localparam  VID_V_BPORCH = 'd10;
    localparam  VID_V_ACTIVE = 'd240;
    localparam  VID_V_TOTAL = 'd512;
    localparam  VID_H_BPORCH = 'd10;
    localparam  VID_H_ACTIVE = 'd320;
    localparam  VID_H_TOTAL = 'd400;

    reg [15:0]  frame_count;
    
    reg [9:0]   x_count;
    reg [9:0]   y_count;
    
    wire [9:0]  visible_x = x_count - VID_H_BPORCH;
    wire [9:0]  visible_y = y_count - VID_V_BPORCH;

    reg [23:0]  vidout_rgb;
    reg         vidout_de;
    reg         vidout_skip;
    reg         vidout_vs;
    reg         vidout_hs;

logic [7:0] pixel_out_r, pixel_out_g, pixel_out_b;
always_comb begin
    vidout_rgb[23:16] = pixel_out_r;
    vidout_rgb[15:8] = pixel_out_g;
    vidout_rgb[7:0] = pixel_out_b;
end
    
always @(posedge clk_core_12288 or negedge reset_n) begin
    if(~reset_n) begin
        x_count <= 0;
        y_count <= 0;
    end else begin
        vidout_de <= 0;
        vidout_skip <= 0;
        vidout_vs <= 0;
        vidout_hs <= 0;
        
        // x and y counters
        x_count <= x_count + 1'b1;
        if(x_count == VID_H_TOTAL-1) begin
            x_count <= 0;
            
            y_count <= y_count + 1'b1;
            if(y_count == VID_V_TOTAL-1) begin
                y_count <= 0;
            end
        end
        
        // generate sync 
        if(x_count == 0 && y_count == 0) begin
            // sync signal in back porch
            // new frame
            vidout_vs <= 1;
            frame_count <= frame_count + 1'b1;
        end
        
        // we want HS to occur a bit after VS, not on the same cycle
        if(x_count == 3) begin
            // sync signal in back porch
            // new line
            vidout_hs <= 1;
        end

        // inactive screen areas are black
        pixel_out_r <= 8'd0;
        pixel_out_g <= 8'd0;
        pixel_out_b <= 8'd0;
        
        // generate active video
        if(x_count >= VID_H_BPORCH && x_count < VID_H_ACTIVE+VID_H_BPORCH) begin
            if(y_count >= VID_V_BPORCH && y_count < VID_V_ACTIVE+VID_V_BPORCH) begin
                // data enable. this is the active region of the line
                vidout_de <= 1;
                
                if (visible_x < 320 && visible_y < 240) begin  // colour square in top-left 256x256 pixels
                    pixel_out_r <= visible_x[7:0];  // 16 horizontal pixels of each red level
                    pixel_out_g <= visible_y[7:0];  // 16 vertical pixels of each green level
                    pixel_out_b <= 8'd64;      // constant blue level
                end else begin  // background colour
                    pixel_out_r <= 8'd0;
                    pixel_out_g <= 8'd16;
                    pixel_out_b <= 8'd48;
                end               
            end 
        end
    end
end
    
endmodule
