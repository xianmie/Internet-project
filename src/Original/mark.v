
module mark (
	input                 clk,           //pixel clock
	input                 rst,           //reset signal high active
	input						 hs,				 //horizontal synchronization
	input						 vs,				 //vertical synchronization
	input						 de,				 //input video data valid
	input[11:0]           h_cnt,         //horizontal active count
	input[11:0]           v_cnt,         //vertical active count
	input						 dilate,			 //dilate data
	output reg[11:0]		 location_x,	 //location
	output reg[11:0]		 location_y,
	output reg				 loc_val,
	output reg[15:0]       vga_data,      //video data output
	output reg				 vga_hs,			 //vga hs output
	output reg				 vga_vs,			 //vga vs output
	output reg				 vga_de			 //vga de output
);
parameter H_TOTAL		=	1024;
parameter V_TOTAL		=	768;
parameter H_RULER		=	1;//1 of 1024
parameter RULER_WIDTH=	8;
parameter SCALE_WIDTH=	3;

parameter START_LINE =	1;//256 of 768
parameter END_LINE	=	766;

parameter ZONE_MAX_THRESHOLD	=	20;//100 of 1024
parameter ZONE_MIN_THRESHOLD	=	12;

reg[11:0] v_cnt_temp;
reg[11:0] zone_cnt;
reg		 zone_busy;
reg[11:0] zone_cnt_delay;
reg[11:0] v_cnt_delay;
reg[11:0] v_cnt_delay_1;

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		vga_data <= 16'hFFFF;
	else if(h_cnt >= H_RULER-RULER_WIDTH && h_cnt <= H_RULER)//where the ruler stands
		vga_data <= 16'hF8;//red
	else if(h_cnt > H_RULER && h_cnt < H_RULER+RULER_WIDTH && v_cnt[3:0] < SCALE_WIDTH)//where the scale of rule stands
		vga_data <= 16'hF8;//red
	else if(dilate==1'b0)
		vga_data <= 16'h0000;
	else
		vga_data <= 16'hFFFF;
end
/*
always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		v_cnt_temp <= 12'd0;
	else if(v_cnt <= START_LINE )
		v_cnt_temp <= 12'd0;
	else if(de==1'b1 && dilate==1'b0 && v_cnt > START_LINE && v_cnt < END_LINE)
		v_cnt_temp <= v_cnt;
	else
		v_cnt_temp <= v_cnt_temp;
end
*/
/*
always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		v_cnt_temp <= 12'd0;
		zone_cnt <= 12'd0;
		zone_cnt_delay <= zone_cnt;
		zone_busy <= 1'b0;
	end
	else if(v_cnt <= START_LINE || v_cnt >= END_LINE)
	begin
		v_cnt_temp <= 12'd0;
		zone_busy <= 1'b0;
	end
	else
	begin
		if(v_cnt_delay_1 == v_cnt && zone_busy == 1'b0)
		begin
			if(de==1'b1 && dilate==1'b0)
				zone_cnt <= zone_cnt + 1;
			else
				zone_cnt <= zone_cnt;
		end
		else
		begin
			if(zone_cnt > ZONE_MAX_THRESHOLD && zone_cnt_delay < ZONE_MIN_THRESHOLD )
			begin
				v_cnt_temp <= v_cnt_delay_1;
				zone_cnt <= 12'd0;
				zone_cnt_delay <= zone_cnt;
				zone_busy <= 1'b1;
			end
			else
				zone_cnt <= 12'd0;
				zone_cnt_delay <= zone_cnt;
		end
	end
end
*/
reg [11:0]	h_left_temp;
reg [11:0]	h_right_temp;
reg [11:0]	v_left_temp;
reg [11:0]	v_right_temp;
reg [11:0]	h_left;
reg [11:0]	h_right;
reg [11:0]	v_left;
reg [11:0]	v_right;
wire[12:0]	sum_h;
wire[12:0]	sum_v;

assign sum_h = h_left + h_right;
assign sum_v = v_left + v_right;

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		h_left_temp <= H_TOTAL;
		h_right_temp <= 12'd0;
		v_left_temp <= 12'd0;
		v_right_temp <= 12'd0;
	end
	else if(v_cnt <= START_LINE || v_cnt >= END_LINE)
	begin
		h_left_temp <= H_TOTAL;
		h_right_temp <= 12'd0;
		v_left_temp <= 12'd0;
		v_right_temp <= 12'd0;
	end
	else
	begin
		if(de==1'b1&&dilate==1'b0)
		begin
			if(h_cnt < h_left_temp)
			begin
				h_left_temp <= h_cnt;
				v_left_temp <= v_cnt;
			end
			else
			begin
				h_left_temp <= h_left_temp;
				v_left_temp <= v_left_temp;
			end
			
			if(h_cnt > h_right_temp)
			begin
				h_right_temp <= h_cnt;
				v_right_temp <= v_cnt;
			end
			else
			begin
				h_right_temp <= h_right_temp;
				v_right_temp <= v_right_temp;
			end
		end
	end
end

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		loc_val <= 1'b0;
		location_x <= 12'd0;
		location_y <= 12'd0;
		h_left <= 12'd0;
		h_right <= 12'd0;
		v_left <= 12'd0;
		v_right <= 12'd0;
	end
	else if(v_cnt_delay==END_LINE-2 && h_cnt==H_TOTAL-2)
	begin
//		location <= v_cnt_temp;
		h_left  <= h_left_temp;
		h_right <= h_right_temp;
		v_left  <= v_left_temp;
		v_right <= v_right_temp;
		location_x <= sum_h[12:1];
		location_y <= sum_v[12:1];
	end
	else if(v_cnt_delay==END_LINE-2 && h_cnt==H_TOTAL-1)
		loc_val <= 1'b1;
	else
		loc_val <= 1'b0;
end

always@(posedge clk)
begin
	vga_hs <= hs;
	vga_vs <= vs;
	vga_de <= de;
	v_cnt_delay <= v_cnt;
	v_cnt_delay_1 <= v_cnt_delay;
end

endmodule 