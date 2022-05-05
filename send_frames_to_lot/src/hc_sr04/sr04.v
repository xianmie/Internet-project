module sr04 (
	input			clk,
	input			rst,
	input			echo,
	output reg	trig,
	output[12:0]	dis
);
parameter TRIG_US			=	10;//trig signal holds 10us
parameter TRIG_CNT_MAX	=	1_000_000;//1MHz, send trig every secend

reg[19:0]	trig_cnt;
reg[15:0]	echo_cnt;
reg[15:0]	echo_cnt_reg;

always@(posedge clk_div or posedge rst)
begin
	if(rst==1'b1)
	begin
		trig <= 1'b0;
		trig_cnt <= 20'd0;
	end
	else if(trig_cnt==TRIG_US-1)
	begin
		trig <= 1'b0;
		trig_cnt <= trig_cnt + 1;
	end
	else if(trig_cnt==TRIG_CNT_MAX-1)
	begin
		trig <= 1'b1;
		trig_cnt <= 20'd0;
	end
	else
	begin
		trig <= trig;
		trig_cnt <= trig_cnt + 1;
	end
end

always@(posedge clk_div or posedge rst)
begin
	if(rst==1'b1)
	begin
		echo_cnt <= 16'd0;
		echo_cnt_reg <= 16'd0;
	end
	else if(echo==1'b1)
	begin
		echo_cnt <= echo_cnt + 1;
		echo_cnt_reg <= echo_cnt + 1;
	end
	else
	begin
		echo_cnt <= 16'd0;
		echo_cnt_reg <= echo_cnt_reg;
	end
end

assign dis = echo_cnt_reg[15:3];//dis = echo_cnt / 8 , which is 0.0013864m by scale
		
clk_div clk_div_m0(
	.clk_50M			(clk),
	.rst				(rst),
	.clk_div			(clk_div)
);

endmodule