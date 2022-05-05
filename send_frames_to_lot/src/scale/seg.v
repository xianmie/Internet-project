module seg(
                input      clk,
                input      rst_n,
					 input[11:0]din,
					 input		din_val,
                output[5:0]seg_sel,
                output[7:0]seg_data
                );
wire[3:0] hun;
wire[3:0] ten;
wire[3:0] one;
wire[3:0] dot;
wire[15:0]bcd;
wire		 bcd_val;
/*assign	hun	=	(bcd_val==1'b1)? bcd[15:12]:hun;
assign	ten	=	(bcd_val==1'b1)? bcd[11:8]:ten;
assign	one	=	(bcd_val==1'b1)? bcd[7:4]:one;
assign	dot	=	(bcd_val==1'b1)? bcd[3:0]:dot;
bin2bcd_12 seg_bcd(
	 .clk			(clk),
	 .nrst		(rst_n),
	 .start		(din_val),
	 .bin			(din),
	 .bcd			(bcd),
	 .valid		(bcd_val)
);
*/
BCD BCD_m0(
	 .binary			(din),
	 .hun				(hun),
	 .ten				(ten),
	 .one				(one),
	 .dot				(dot),
);


wire[6:0] seg_data_0;
seg_decoder seg_decoder_m0(
    .bin_data  (4'd0),
    .seg_data  (seg_data_0)
);
wire[6:0] seg_data_1;
seg_decoder seg_decoder_m1(
    .bin_data  (4'd0),
    .seg_data  (seg_data_1)
);
wire[6:0] seg_data_2;
seg_decoder seg_decoder_m2(
    .bin_data  (hun),
    .seg_data  (seg_data_2)
);
wire[6:0] seg_data_3;
seg_decoder seg_decoder_m3(
    .bin_data  (ten),
    .seg_data  (seg_data_3)
);
wire[6:0] seg_data_4;
seg_decoder seg_decoder_m4(
    .bin_data  (one),
    .seg_data  (seg_data_4)
);

wire[6:0] seg_data_5;
seg_decoder seg_decoder_m5(
    .bin_data  (dot),
    .seg_data  (seg_data_5)
);

seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .seg_data_0 ({1'b1,7'b1111111}),      //The  decimal point at the highest bit,and low level effecitve
    .seg_data_1 ({1'b1,7'b1111111}), 
    .seg_data_2 ({1'b1,seg_data_2}),
    .seg_data_3 ({1'b1,seg_data_3}),
    .seg_data_4 ({1'b0,seg_data_4}),
    .seg_data_5 ({1'b1,seg_data_5})
);
endmodule 