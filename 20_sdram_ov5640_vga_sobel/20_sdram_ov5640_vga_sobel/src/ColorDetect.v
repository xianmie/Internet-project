module ColorDetect (
	input			clk,
	input			rst,
	input			hsv_hs,
	input			hsv_vs,
	input			hsv_de,
	input[23:0] hsv,
	output 		color_hs,
	output 		color_vs,
	output 		color_de,
	output 		color
);

parameter S_THRESHOLD = 80;
parameter V_THRESHOLD = 180;

wire[7:0]	hue,saturation,value;
assign hue			=	hsv[23:16];//ignored
assign saturation	=	hsv[15:8];
assign value		=	hsv[7:0];

assign color		=	(saturation >= S_THRESHOLD && value >= V_THRESHOLD)? 1'b0:1'b1;
assign color_hs	=	hsv_hs;
assign color_vs	=	hsv_vs;
assign color_de	=	hsv_de;


endmodule