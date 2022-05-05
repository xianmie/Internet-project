module transform(input clk,
				 input rst_n,
				 input en,
				 input [8:0] data_in,
				 input read,
				 output reg finish,
				 output reg [31:0] data_out
);

wire [31:0] data_out_r;
reg [1:0] state;
reg [1:0] next_state;
reg [23:0] data_to_trans;
reg [1:0] cnt;

localparam IDLE=1;
localparam WORK=2;
localparam WAIT=3;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		state<=IDLE;
	else
		state<=next_state;
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt<=0;
	else if(state==WORK) begin
		if(cnt<3)
			cnt<=cnt+1;
		else
			cnt<=0;
	end
end		

always@(*) begin
	case(state)
		IDLE:
			if(en)
				next_state<=WORK;
			else
				next_state<=IDLE;
		WORK:
			if(cnt==3)
				next_state<=WAIT;
			else
				next_state<=WORK;
		WAIT:
			if(read)
				next_state<=IDLE;
			else
				next_state<=WAIT;
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		finish<=0;
	else if(state==WORK) 
		data_out<=data_out_r;
	else if(state==WAIT)
		finish<=1;
	else if(state==IDLE)
		finish<=0;
end

transform_base64 m0(clk,rst_n,data_in[23:0],data_out_r[31:0]);


endmodule