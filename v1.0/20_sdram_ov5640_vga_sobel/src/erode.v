module erode(
	input			rst_n,
	input			pclk,
	input			sobel_hs,
	input			sobel_vs,
	input			sobel_de,
	input			sobel_din,
	output		erode_hs,
	output		erode_vs,
	output		erode_de,
	output		erode_dout
);

reg  		  p11,p12,p13;
reg  		  p21,p22,p23;
reg  		  p31,p32,p33;
wire 		  p1,p2,p3;

reg		  erode1,erode2,erode3;
reg		  erode;

reg [7:0] hs_buf ;
reg [7:0] vs_buf ;
reg [7:0] de_buf ;

linebuffer_Wapper#
(
	.no_of_lines(3),
	.samples_per_line(640),
	.data_width(1)
)
 linebuffer_Wapper_m2(
	.ce         (1'b1   ),
	.wr_clk     (pclk   ),
	.wr_en      (sobel_de   ),
	.wr_rst     (~rst_n   ),
	.data_in    (sobel_din),
	.rd_en      (sobel_de   ),
	.rd_clk     (pclk   ),
	.rd_rst     (~rst_n   ),
	.data_out   ({p3,p2,p1}  )
   );
	
always@(posedge pclk)
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

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		erode1 <= 1'b0;
		erode2 <= 1'b0;
		erode3 <= 1'b0;
	end
	else
	begin
		erode1 <= p11 & p12 & p13;
		erode2 <= p21 & p22 & p23;
		erode3 <= p31 & p32 & p33;
	end
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		erode <= 1'b0;
	end
	else
	begin
		erode <= erode1 & erode2 & erode3;
	end
end


//hs vs de delay 7 clock
always@(posedge pclk or negedge rst_n)
begin
  if (!rst_n)
  begin
    hs_buf <= 7'd0 ;
    vs_buf <= 7'd0 ;
    de_buf <= 7'd0 ;
  end
  else
  begin
    hs_buf <= {hs_buf[5:0], sobel_hs} ;
	 vs_buf <= {vs_buf[5:0], sobel_vs} ;
	 de_buf <= {de_buf[5:0], sobel_de} ;
  end
end

assign erode_hs = hs_buf[6] ;
assign erode_vs = vs_buf[6] ;
assign erode_de = de_buf[6] ;
assign erode_dout  = erode;
	 

endmodule