module rgb2hsv (
	input			clk,
	input			rst,
	input			median_hs,
	input			median_vs,
	input			median_de,
	input[23:0]	median,
	output reg	hsv_hs,
	output reg	hsv_vs,
	output reg	hsv_de,
	output[23:0]hsv
);

wire[7:0]	red,green,blue;
wire[7:0]	hue,saturation,value;

assign red	=	median[23:16];
assign green=	median[15:8];
assign blue	=	median[7:0];

assign hsv	=	{hue,saturation,value};

reg[7:0]		max;
reg[7:0]		min;

assign hue	=	8'd0;//ignored
assign saturation = max - min;
assign value=	max;

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		max <= 8'd0;
		min <= 8'd0;
	end
	else if(red >= green)
	begin
		if(red >= blue)
			max <= red;
		else
			max <= blue;
		if(green <= blue)
			min <= green;
		else
			min <= blue;
	end
	else
	begin
		if(green >= blue)
			max <= green;
		else
			max <= blue;
		if(red <= blue)
			min <= red;
		else
			min <= blue;
	end
end

always@(posedge clk)
begin
	hsv_hs <= median_hs;
	hsv_vs <= median_vs;
	hsv_de <= median_de;
end
endmodule