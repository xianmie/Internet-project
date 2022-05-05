module dilate(
	input			rst_n,
	input			pclk,
	input			erode_hs,
	input			erode_vs,
	input			erode_de,
	input			erode_din,
	output		dilate_hs,
	output		dilate_vs,
	output		dilate_de,
	output		dilate_dout
);

reg  		  p11,p12,p13;
reg  		  p21,p22,p23;
reg  		  p31,p32,p33;
wire 		  p1,p2,p3;

reg		  dilate1,dilate2,dilate3;
reg		  dilate;

reg [7:0] hs_buf ;
reg [7:0] vs_buf ;
reg [7:0] de_buf ;

linebuffer_Wapper#
(
	.no_of_lines(3),
	.samples_per_line(640),
	.data_width(1)
)
 linebuffer_Wapper_m3(
	.ce         (1'b1   ),
	.wr_clk     (pclk   ),
	.wr_en      (erode_de   ),
	.wr_rst     (~rst_n   ),
	.data_in    (erode_din),
	.rd_en      (erode_de   ),
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
		dilate1 <= 1'b0;
		dilate2 <= 1'b0;
		dilate3 <= 1'b0;
	end
	else
	begin
		dilate1 <= p11 || p12 || p13;
		dilate2 <= p21 || p22 || p23;
		dilate3 <= p31 || p32 || p33;
	end
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		dilate <= 1'b0;
	end
	else
	begin
		dilate <= dilate1 || dilate2 || dilate3;
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
    hs_buf <= {hs_buf[5:0], erode_hs} ;
	 vs_buf <= {vs_buf[5:0], erode_vs} ;
	 de_buf <= {de_buf[5:0], erode_de} ;
  end
end

assign dilate_hs = hs_buf[6] ;
assign dilate_vs = vs_buf[6] ;
assign dilate_de = de_buf[6] ;
assign dilate_dout  = dilate;
	 

endmodule