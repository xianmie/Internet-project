 module at_tx(
				input clk,				
				input rst_n,
				input[5119:0] data_in,
				input reg data_valid;
				output[7:0] data_out,
				output reg front_over;
 )
 
 reg[7:0] data_out_r;
 reg[2:0] cnt;
 reg[8:0] cnt1;
 reg[10:0] cnt2;
 reg[3:0] cnt3;
 reg[2:0] state;
 reg[2:0] next_state;
 reg[1255:0] front_r;
 reg[55:0] ending_r;
 reg[5119:0] data_in_r,
 reg flag1;
 reg flag3;
 reg flag3;
 reg done;
 reg front_over;
 reg ending_over;
 reg data_over;
 wire[55:0] ending;
 
 localparam IDLE;
 localparam SEND_FRONT;
 localparam SEND_dATA;
 localparam SEND_ENDING;
 localparam front=1256'b01000001_01010100_00101011_01001101_01010001_01010100_01010100_01010000_01010101_
              01000010_00111101_00100010_00100100_01101111_01100011_00101111_01100100_01100101_01110110_
			  01101001_01100011_01100101_01110011_00101111_00110110_00110001_00110010_01100110_00111000_
			  00110001_00111000_00110011_00110010_01100011_01100011_01100101_00110100_01100110_00110000_
			  00110010_00111000_00110110_00110010_00110011_00110011_00110100_01100101_01100011_01011111_
			  01101101_01110011_01000101_01111001_01100101_01011111_01110100_01100101_01110011_01110100_
			  00101111_01110011_01111001_01110011_00101111_01110000_01110010_01101111_01110000_01100101_
			  01110010_01110100_01101001_01100101_01110011_00101111_01110010_01100101_01110000_01101111_
			  01110010_01110100_00100010_00101100_00110000_00101100_00110001_00101100_00110001_00101100_
			  00100010_01111011_01011100_00100010_01110011_01100101_01110010_01110110_01101001_01100011_
			  01100101_01110011_01011100_00100010_00111010_01011011_01111011_01011100_00100010_01110011_
			  01100101_01110010_01110110_01101001_01100011_01100101_01011111_01101001_01100100_01011100_
			  00100010_00111010_01011100_00100010_01101001_01101101_01100001_01100111_01100101_01011100_
			  00100010_00101100_01011100_00100010_01110000_01110010_01101111_01110000_01100101_01110010_
			  01110100_01101001_01100101_01110011_01011100_00100010_00111010_01111011_01011100_00100010_
			  01110010_01100001_01110111_01011100_00100010_00111010_01011100_00100010;
 

localparam ending=56'b01011100_00100010_01111101_01111101_01011101_01111101_00100010;

assign data_out= !rst_n? 0: data_out_r;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state<=IDLE;
	else
		state<=next_state;
end
	
//cnt1
always@(posedge clk or negedge rst_n) begin
	if((!rst_n) ||(!flag1))
		cnt1<=0;
	if(flag1)
		cnt1<=cnt1+1;
end
//cnt2
always@(posedge clk or negedge rst_n) begin
	if((!rst_n) ||(!flag2))
		cnt2<=0;
	if(flag2)
		cnt2<=cnt2+1;
end
//cnt3
always@(posedge clk or negedge rst_n) begin
	if((!rst_n) ||(!flag3))
		cnt3<=0;
	if(flag3)
		cnt3<=cnt3+1;
end
always@(*) begin
	case(state)
		IDLE:
			if(data_valid)
				next_state<=SEND_FRONT;
			else
				next_state<=IDLE;
		SEND_FRONT:
			if(front_over)
				next_state<=SEND_dATA;
			else
				next_state<=SEND_FRONT;
	    SEND_dATA:
			if(data_over)
				next_state<=SEND_ENDING;
			else
				next_state<=SEND_dATA;
		SEND_ENDING:
			if(ending_over) 
				next_state<=IDLE;
			else
				next_state<=SEND_ENDING;
	endcase
end

//cnt
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt<=0;
	else begin
		if(front_over)
			cnt<=cnt+1;
		if(done)
			cnt<=0;
	end
end

always@(posedge clk) begin
	if(state==SEND_FRONT) begin
		front_over<=0;
		data_in_r<=data_in;
		if(cnt1<157) begin
			data_out_r<=front_r[1255:1248];
			front_r<=front_r<<8;
			flag1<=1;
		end
		else begin
			front_over<=1;
			front_r<=front;
			flag1<=0;
		end
	end
	if(state==SEND_dATA) begin
		data_over<=0;
		if(cnt==1) begin
			data_out_r<=8'b01011011;//[
		end
		if(cnt==3)
			data_out_r<=8'b01011101;//]
		if(cnt==2) begin
			if(cnt2<640) begin
				data_out_r<=data_in_r[5119:5112];
				data_in_r<=data_in_r<<8;
				flag2<=1;
			end
			else begin
				data_over<=1;
				flag2<=0;
				done<=1;
			end
		end
		
	end
	if(state==SEND_ENDING) begin
		ending_over<=0;
		if(cnt3<7) begin
			data_out_r<=ending_r[55:48];
			ending_r<=ending_r<<8;
			flag3<=1;
		end
		else begin
			ending_over<=1;
			ending_r<=ending;
			flag3<=0;
		end
	end
end
endmodule				
				
			