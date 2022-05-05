module osd_display(
	input                       rst_n,   
	input                       pclk,
	input								 key,
	input[23:0]                 wave_color,
	input                       adc_clk,
	input                       adc_buf_wr,
	input[11:0]                 adc_buf_addr,
	input[7:0]                  adc_buf_data,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[15:0]                 i_data,  
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output[15:0]                o_data
);
parameter OSD_WIDTH   =  12'd160;
parameter OSD_HEGIHT  =  12'd32;

wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[15:0] pos_data;
reg[15:0]  v_data;
reg[11:0]  osd_x;
reg[11:0]  osd_y;
reg[15:0]  osd_ram_addr;
wire[7:0]  q;
reg [7:0]  q_r;
wire[7:0]  q_33;
wire[7:0]  q_32;
wire[7:0]  q_31;
wire[7:0]  q_30;
wire[7:0]  q_29;
wire[7:0]  q_28;

assign q = q_r;

wire		key_pose;

ax_debounce ax_debounce_m0(
		.clk						(pclk),
		.rst						(~rst_n),
		.button_in				(key),
		.button_posedge		(key_pose),
		.button_negedge		(),
		.button_out				()
);

reg[3:0]	cnt;

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		cnt<=4'd0;
	else if(key_pose==1'b1 && cnt==4'd4)
		cnt <= 4'd0;
	else if(key_pose==1'b1)
		cnt <= cnt +1;
	else
		;
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		q_r <= 8'd0;
	end
	else
		case(cnt)
		4'd0 : begin
			q_r <= q_32;
		end
		4'd1 : begin
			q_r <= q_31;
		end
		4'd2 : begin
			q_r <= q_30;
		end
		4'd3 : begin
			q_r <= q_29;
		end
		4'd4 : begin
			q_r <= q_28;
		end
		default : q_r <= q_r;
		endcase
end

reg        region_active;
reg        region_active_d0;
reg        region_active_d1;
reg        region_active_d2;

reg        pos_vs_d0;
reg        pos_vs_d1;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;
//delay 1 clock 
always@(posedge pclk)
begin
	if(pos_y >= 12'd9 && pos_y <= 12'd9 + OSD_HEGIHT - 12'd1 && pos_x >= 12'd9 && pos_x  <= 12'd9 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge pclk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

always@(posedge pclk)
begin
	pos_vs_d0 <= pos_vs;
	pos_vs_d1 <= pos_vs_d0;
end

//delay 2 clock
//region_active_d0
always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end

always@(posedge pclk)
begin
	if(pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0)
		osd_ram_addr <= 16'd0;
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1;
end


always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		if(q[osd_x[2:0]] == 1'b1)
			v_data <= 16'b11111_000000_00000;
		else
			v_data <= pos_data;
	else
		v_data <= pos_data;
end

osd_rom osd_rom_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_33)
);

osd_32 osd_32_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_32)
);

osd_31 osd_31_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_31)
);

osd_30 osd_30_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_30)
);

osd_29 osd_29_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_29)
);

osd_28 osd_28_m0
(
	.address(osd_ram_addr[15:3]),
	.clock(pclk),
	.q(q_28)
);

timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule