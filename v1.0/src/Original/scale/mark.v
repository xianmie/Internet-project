
module mark (
	input                 clk,           //pixel clock
	input						 clk_50M,		 //50M Hz clock
	input                 rst,           //reset signal high active
	input						 hs,				 //horizontal synchronization
	input						 vs,				 //vertical synchronization
	input						 de,				 //input video data valid
	input[11:0]           h_cnt,         //horizontal active count
	input[11:0]           v_cnt,         //vertical active count
	input[7:0]				 ycbcr_y,
	output reg[15:0]      vga_data,      //video data output
	output 					 vga_hs,			 //vga hs output
	output 					 vga_vs,			 //vga vs output
	output 					 vga_de,			 //vga de output
	output[5:0]				 seg_sel,
   output[7:0]				 seg_data
);
parameter H_TOTAL		=	480;
parameter V_TOTAL		=	640;
parameter V_RULER_START	=	400;//384 of 768
parameter V_RULER_END=	490;
parameter H_RULER_START = 75;
parameter H_RULER_END=	405;
parameter RULER_WIDTH=	4;
parameter SCALE_WIDTH=	2;

parameter START_LINE =	1;//256 of 768
parameter END_LINE	=	637;

parameter ZONE_MAX_THRESHOLD	=	20;//100 of 1024
parameter ZONE_MIN_THRESHOLD	=	12;

parameter GRAY_THRESHOLD = 70;//70 of 255;
parameter RED_THRESHOLD	=	50;

parameter LEFT = 80;
parameter RIGHT= 400;

reg  [7:0]  p11,p12,p13;
reg  [7:0]  p21,p22,p23;
reg  [7:0]  p31,p32,p33;
wire [7:0]  p1,p2,p3;

linebuffer_Wapper#
(
	.no_of_lines(3),
	.samples_per_line(640),
	.data_width(8)
)
 linebuffer_Wapper_m11(
	.ce         (1'b1   ),
	.wr_clk     (clk   ),
	.wr_en      (de   ),
	.wr_rst     (rst   ),
	.data_in    (ycbcr_y),
	.rd_en      (de   ),
	.rd_clk     (clk   ),
	.rd_rst     (rst   ),
	.data_out   ({{p3,p2,p1}}  )
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



always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		vga_data <= {p22[7:3],p22[7:2],p22[7:3]};
	end
	else if(v_cnt >= V_RULER_START-1 && v_cnt <= V_RULER_START+1 && h_cnt >= H_RULER_START && h_cnt <= H_RULER_END)//where the ruler stands
		vga_data <= 16'h001F;//red
	else if(v_cnt > V_RULER_START && v_cnt < V_RULER_END && h_cnt >= H_RULER_START && h_cnt <= H_RULER_END)
	begin
		if(h_cnt==LEFT || h_cnt==RIGHT || h_cnt==pointer)
			vga_data <= 16'h07E0;//green
		else if(p22 < GRAY_THRESHOLD && p21 < GRAY_THRESHOLD && p31 < GRAY_THRESHOLD)
			vga_data <= 16'hF800;//blue
		else if(p22 < GRAY_THRESHOLD)
			vga_data <= 16'd0000;
		else
			vga_data <= 16'hFFFF;
	end
	else if(p22 < GRAY_THRESHOLD)
		vga_data <= 16'h0000;
	else
		vga_data <= 16'hFFFF;
end

reg [11:0]		pointer;
reg [11:0]		pointer_temp;
reg [11:0]		pointer_delay;
reg				pointer_val;


reg				vs_delay;
wire				vs_nege;
assign	vs_nege	=	~vga_vs & vs_delay;

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		pointer_temp <= 12'd0;
	else if(v_cnt>V_RULER_START-30 && v_cnt<V_RULER_START-15 && h_cnt>H_RULER_START && h_cnt<H_RULER_END 
			&& p22 < GRAY_THRESHOLD)
		pointer_temp <= h_cnt+2;
	else
		;
end

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		pointer <= 12'd0;
		pointer_delay <= 12'd0;
		pointer_val <= 1'b0;
	end
//	else if(pointer_temp==pointer_delay)
//		pointer <= 12'd0;
	else if(vs_nege==1'b1)
	begin
		pointer <= pointer_temp;
		pointer_delay <= pointer;
		pointer_val <= 1'b1;
	end
	else
		pointer_val <= 1'b0;
end





always@(posedge clk)
begin
	vs_delay <= vga_vs;
end


//-------------------------------------------------------------
// tube display
//-------------------------------------------------------------
wire[11:0]		scale;
assign	scale	=	500*(pointer-LEFT)/(RIGHT-LEFT);
seg seg_mark_m0(
		.clk(clk_50M),  
		.rst_n(~rst),
		.din(scale),  //12bit
		.din_val(pointer_val),
		.seg_sel(seg_sel),
		.seg_data(seg_data)
	);

reg[5:0]		hs_buf;
reg[5:0]		vs_buf;
reg[5:0]		de_buf;

//hs vs de delay 6 clock
always@(posedge clk or posedge rst)
begin
  if (rst)
  begin
    hs_buf <= 6'd0 ;
    vs_buf <= 6'd0 ;
    de_buf <= 6'd0 ;
  end
  else
  begin
    hs_buf <= {hs_buf[4:0], hs} ;
	 vs_buf <= {vs_buf[4:0], vs} ;
	 de_buf <= {de_buf[4:0], de} ;
  end
end

assign vga_hs = hs_buf[0] ;
assign vga_vs = vs_buf[0] ;
assign vga_de = de_buf[0] ;

endmodule 