module transform(input clk,
				 input rst_n,
				 input data_valid,
				 input [3839:0] data_in,
				 input reg read;
				 output finish;
				 output reg [5119:0] data_out
);

reg [5119:0] data_out_r;
reg [1:0] state;
reg [1:0] next_state;
reg finish;

localparam IDLE;
localparam WORK;
localparam WAIT;


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state<=IDLE;
	else
		state<=next_state;
end

always@(*) begin
	case(state)
		IDLE:
			if(data_valid)
				next_state<=WORK;
			else
				next_state<=IDLE;
		WORK:
				next_state<=WAIT;
		WAIT:
			if(read)
				next_state<=IDLE;
			else
				read;
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(state==WORK) 
		data_out<=data_out_r;
	if(state==WAIT)
		finish<=1;
	if(state==IDLE)
		finish<=0;
end

transform_base64 m0(clk,rst_n,data_in[479:0],data_out_r[639:0]);
transform_base64 m1(clk,rst_n,data_in[959:480],data_out_r[1279:640]);
transform_base64 m2(clk,rst_n,data_in[1439:960],data_out_r[1919:1280]);
transform_base64 m3(clk,rst_n,data_in[1919:1440],data_out_r[2559:1920]);
transform_base64 m4(clk,rst_n,data_in[2399:1920],data_out_r[3199:2560]);
transform_base64 m5(clk,rst_n,data_in[2879:2400],data_out_r[3839:3200]);
transform_base64 m6(clk,rst_n,data_in[3359:2880],data_out_r[4479:3840]);
transform_base64 m7(clk,rst_n,data_in[3839:3360],data_out_r[5119:4480]);

endmodule

	