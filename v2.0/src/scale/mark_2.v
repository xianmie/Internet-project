
module mark_2 (
	input                 clk,           //pixel clock
	input                 rst,           //reset signal high active
	input						 num_rst_n,		 //number count rst_n
	input						 hs,				 //horizontal synchronization
	input						 vs,				 //vertical synchronization
	input						 de,				 //input video data valid
	input[11:0]           h_cnt,         //horizontal active count
	input[11:0]           v_cnt,         //vertical active count
	input						 dilate,			 //dilate data
	output reg[15:0]      vga_data,      //video data output
	output 					 vga_hs,			 //vga hs output
	output 					 vga_vs,			 //vga vs output
	output 					 vga_de,			 //vga de output
	output[5:0]				 seg_sel,
   output[7:0]				 seg_data,
	output					 buzzer
);
parameter H_TOTAL		=	640;
parameter V_TOTAL		=	480;
parameter V_RULER_START	=	143;//143 of 480
parameter V_RULER_END=	337;
parameter H_RULER_START = 256;
parameter H_RULER_END=	276;
parameter CHECKLINE	=	H_RULER_START + 7;
parameter SCALE_THRESHOLD = 5;
parameter POINTER	=	240;//240 of 480

reg  		  p11,p12,p13;
reg  		  p21,p22,p23;
reg  		  p31,p32,p33;
wire 		  p1,p2,p3;

linebuffer_Wapper#
(
	.no_of_lines(3),
	.samples_per_line(640	),
	.data_width(1)
)
 linebuffer_Wapper_m11(
	.ce         (1'b1   ),
	.wr_clk     (clk   ),
	.wr_en      (de   ),
	.wr_rst     (rst   ),
	.data_in    (dilate),
	.rd_en      (de   ),
	.rd_clk     (clk   ),
	.rd_rst     (rst   ),
	.data_out   ({p3,p2,p1}  )
   );
	
	
always@(posedge clk)
begin
	p11 <= p1;
	p21 <= p2;
	p31 <= p3;
	
	p12 <= p11;
	p22 <= p21;
	p32 <= p31;
	
	p13 <= p12;
	p23 <= p22;
	p33 <= p32;
end	

reg				vga_vs_delay;
wire				vga_vs_nege;
assign	vga_vs_nege =	vga_vs_delay & ~vga_vs;

always@(posedge clk)
begin
	vga_vs_delay <= vga_vs;
end


reg 				frame_cnt;

always@(posedge clk or negedge num_rst_n)
begin
	if(!num_rst_n)
		frame_cnt <= 1'b0;
	else if(vga_vs_nege==1'b1) //end of a frame
		frame_cnt <= frame_cnt +1;
	else
		frame_cnt <= frame_cnt;
end
	
reg [11:0]		vcount_top;
reg [11:0]		vcount_bottom;
reg [11:0]		vcount_top_temp;
reg [11:0]		vcount_bottom_temp;
reg [11:0]		vcount_bottom_delay;
	
always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		vga_data <= 16'hFFFF;
		
//detecting box
	else if(v_cnt==POINTER)
		if(h_cnt>H_RULER_START-70 && h_cnt<H_RULER_START-35)
			vga_data <= 16'hF800;//red
		else if(p22==1'b1)
			vga_data <= 16'hFFFF;
		else
			vga_data <= 16'h0000;
	else if(v_cnt==V_RULER_START || v_cnt==V_RULER_END)
		if(h_cnt>H_RULER_START && h_cnt<H_RULER_END)
			vga_data <= 16'hF800;//red
		else if(p22==1'b1)
			vga_data <= 16'hFFFF;
		else
			vga_data <= 16'h0000;
	else if(h_cnt==H_RULER_START || h_cnt==H_RULER_END)
		if(v_cnt>V_RULER_START && v_cnt<V_RULER_END)
			vga_data <= 16'hF800;//red
		else if(p22==1'b1)
			vga_data <= 16'hFFFF;
		else
			vga_data <= 16'h0000;

//scale			
	else if(v_cnt==vcount_top)
		if(h_cnt>H_RULER_START && h_cnt<H_RULER_END)
			vga_data <= 16'h001F;//blue
		else if(p22==1'b1)
			vga_data <= 16'hFFFF;
		else
			vga_data <= 16'h0000;
	else if(v_cnt==vcount_bottom)
		if(h_cnt>H_RULER_START && h_cnt<H_RULER_END)
			vga_data <= 16'h001F;//blue
		else if(p22==1'b1)
			vga_data <= 16'hFFFF;
		else
			vga_data <= 16'h0000;
			
	else if(p22==1'b1)
		vga_data <= 16'hFFFF;
	else
		vga_data <= 16'h0000;
end

wire[11:0]		vcount_sub;
assign	vcount_sub	=	vcount_bottom_temp - vcount_top_temp;


always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		vcount_top_temp <= 12'd100;
		vcount_bottom_temp <= 12'd100;
	end
	else if(vga_vs_nege==1'b1)
	begin
		vcount_top_temp <= 12'd100;
		vcount_bottom_temp <= 12'd100;
	end
	else if(v_cnt>V_RULER_START && v_cnt<V_RULER_END) //reach detecting box
	begin
		if(h_cnt==CHECKLINE) //reach checkline
			if(vertical_line==1'b1) //total 10 vertical dilate pixels
			//if(~p11&~p12&~p13&~p21&~p22&~p23&~p31&~p32&~p33)	//total 3x3 dark
				if(v_cnt<vcount_top_temp-SCALE_THRESHOLD ||v_cnt>vcount_top_temp+SCALE_THRESHOLD 
					|| v_cnt<vcount_bottom_temp-SCALE_THRESHOLD ||v_cnt>vcount_bottom_temp+SCALE_THRESHOLD)	//far away from the blue line we drew
					if(v_cnt < POINTER)	//top line
						vcount_top_temp <= v_cnt;
					else	//bottom line
						vcount_bottom_temp <= v_cnt;
	end
end

always@(posedge clk or negedge num_rst_n)
begin
	if(!num_rst_n)
	begin
		vcount_top <= 12'd100;
		vcount_bottom <= 12'd100;
		vcount_bottom_delay <= 12'd100;
	end
	else if(vga_vs_nege==1'b1)
	begin
		vcount_top <= vcount_top_temp;
		vcount_bottom <= vcount_bottom_temp;
		vcount_bottom_delay <= vcount_bottom;
	end
	else
	begin
		vcount_top <= vcount_top;
		vcount_bottom <= vcount_bottom;
		vcount_bottom_delay <= vcount_bottom;
	end
end

reg [4:0]		num_1/*synthesis noprune*/;
wire[7:0]		num_5/*synthesis keep*/;
assign	num_5	=	num_1 *5 ;

always@(posedge clk or negedge num_rst_n)
begin
	if(!num_rst_n)
	begin
		num_1 <= 5'd0;
	end
	else if(vcount_bottom_delay < POINTER+50 && vcount_bottom > V_RULER_END-50)
	//else if(vcount_bottom>V_RULER_END-SCALE_THRESHOLD && vcount_bottom<POINTER+SCALE_THRESHOLD) //find new scale
	begin
		if(num_1 == 19)
			num_1 <= 5'd0;
		else
			num_1 <= num_1 + 1;
	end
end

//-------------------------------------------------------------
// tube display
//-------------------------------------------------------------
wire[11:0]	result;
wire[11:0]	scale;
assign scale = (POINTER>vcount_top && vcount_bottom>vcount_top)? 50*(POINTER-vcount_top)/(vcount_bottom-vcount_top):12'd0;
assign result=	num_5*10 + scale;
seg seg_mark_m2(
		.clk(clk),  
		.rst_n(~rst & num_rst_n),
		.din(result),  //12bit
		.seg_sel(seg_sel),
		.seg_data(seg_data)
	);

reg[6:0]		hs_buf;
reg[6:0]		vs_buf;
reg[6:0]		de_buf;

//-------------------------------------------------------------
// buzzer
//-------------------------------------------------------------
reg[23:0]	timer;
wire			buzzer_en;
reg[11:0]	scale_r0;
reg[11:0]	scale_r1;
reg[11:0]	scale_r2;
reg[11:0]	scale_r3;

assign	buzzer_en	=	(scale_r0<scale_r1 &&scale_r1<scale_r2 &&scale_r2<scale_r3)? 1'b1:1'b0;

always@(posedge clk or negedge num_rst_n)
begin
	if(!num_rst_n)
		timer <= 24'd0;
	else if(timer==7_244_999)	//100ms
		timer <= 24'd0;
	else
		timer <= timer + 1;
end

always@(posedge clk or negedge num_rst_n)
begin
	if(!num_rst_n)
	begin
		scale_r0 <= 12'd0;
		scale_r1 <= 12'd0;
		scale_r2 <= 12'd0;
		scale_r3 <= 12'd0;
	end
	else if(timer==7_244_999)	//record per 100ms
	begin
		scale_r0 <= scale;
		scale_r1 <= scale_r0;
		scale_r2 <= scale_r1;
		scale_r3 <= scale_r2;
	end
	else
		;
end

buzzer_pwm_test buzzer_pwm_test_m0(
	.clk		(clk),
	.rst_n	(num_rst_n),	
	.key1		(buzzer_en),	//posedge enable
	.buzzer	(buzzer)
);

//hs vs de delay 7 clock
always@(posedge clk or posedge rst)
begin
  if (rst==1'b1)
  begin
    hs_buf <= 7'd0 ;
    vs_buf <= 7'd0 ;
    de_buf <= 7'd0 ;
  end
  else
  begin
    hs_buf <= {hs_buf[5:0], hs} ;
	 vs_buf <= {vs_buf[5:0], vs} ;
	 de_buf <= {de_buf[5:0], de} ;
  end
end

assign vga_hs = hs_buf[6] ;
assign vga_vs = vs_buf[6] ;
assign vga_de = de_buf[6] ;

reg [9:0]		data_buf;//dilate data delay 10 clock
wire				vertical_line;//find 10 vertical pixel signal
always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		data_buf <= 10'd0;
	end
	else
	begin
		data_buf <= {data_buf[8:0],p22};
	end
end

assign vertical_line	=	(data_buf==10'b00_0000_0000)? 1'b1:1'b0;

endmodule 