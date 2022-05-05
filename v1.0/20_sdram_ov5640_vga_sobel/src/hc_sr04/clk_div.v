module clk_div (
	input			clk_50M,
	input			rst,
	output reg	clk_div
);
parameter CNT_THRESHOLD		=	25;// clk_div freq = 50_000_000 / (CNT_THRESHOLD*2), which is 1MHz for now

reg[15:0] cnt;

always@(posedge clk_50M or posedge rst)
begin
	if(rst==1'b1)
		cnt <= 16'd0;
	else if(cnt==CNT_THRESHOLD-1)
		cnt <= 16'd0;
	else
		cnt <= cnt + 1;
end

always@(posedge clk_50M or posedge rst)
begin
	if(rst==1'b1)
		clk_div <= 1'b0;
	else if(cnt==CNT_THRESHOLD-1)
		clk_div <= ~clk_div;
	else
		clk_div <= clk_div;
end

endmodule