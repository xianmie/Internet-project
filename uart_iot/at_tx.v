 module at_tx(
				input clk,				
				input rst_n,
				input[5119:0] data_in,
				input  data_valid,
				input tx_data_already,
				output[7:0] data_out,
				output reg done,//读下一次数据
				output reg data_out_valid
 );
 
 reg[7:0] data_out_r;
 reg[7:0] cnt1;
 reg[9:0] cnt2;
 reg[2:0] cnt3;
 reg[3:0] state;
 reg[3:0] next_state;
 reg[1255:0] front_r;
 reg[55:0] ending_r;
 reg[5119:0] data_in_r;
 reg flag1;
 reg flag2;
 reg flag3;
 reg ending_over;
 reg data_over;
 reg front_over;
 
 localparam IDLE=1;
 localparam SEND_FRONT1=2;
 localparam SEND_dATA1=3;
 localparam SEND_ENDING1=4;
 localparam SEND_FRONT2=5;
 localparam SEND_dATA2=6;
 localparam SEND_ENDING2=7;
 localparam SEND_FRONT3=8;
 localparam SEND_dATA3=9;
 localparam SEND_ENDING3=10;
 localparam front=1256'b01000001_01010100_00101011_01001101_01010001_01010100_01010100_01010000_01010101_01000010_00111101_00100010_00100100_01101111_01100011_00101111_01100100_01100101_01110110_01101001_01100011_01100101_01110011_00101111_00110110_00110001_00110010_01100110_00111000_00110001_00111000_00110011_00110010_01100011_01100011_01100101_00110100_01100110_00110000_00110010_00111000_00110110_00110010_00110011_00110011_00110100_01100101_01100011_01011111_01101101_01110011_01000101_01111001_01100101_01011111_01110100_01100101_01110011_01110100_00101111_01110011_01111001_01110011_00101111_01110000_01110010_01101111_01110000_01100101_01110010_01110100_01101001_01100101_01110011_00101111_01110010_01100101_01110000_01101111_01110010_01110100_00100010_00101100_00110000_00101100_00110001_00101100_00110001_00101100_00100010_01111011_01011100_00100010_01110011_01100101_01110010_01110110_01101001_01100011_01100101_01110011_01011100_00100010_00111010_01011011_01111011_01011100_00100010_01110011_01100101_01110010_01110110_01101001_01100011_01100101_01011111_01101001_01100100_01011100_00100010_00111010_01011100_00100010_01101001_01101101_01100001_01100111_01100101_01011100_00100010_00101100_01011100_00100010_01110000_01110010_01101111_01110000_01100101_01110010_01110100_01101001_01100101_01110011_01011100_00100010_00111010_01111011_01011100_00100010_01110010_01100001_01110111_01011100_00100010_00111010_01011100_00100010;
 

localparam ending=56'b01011100_00100010_01111101_01111101_01011101_01111101_00100010;

assign data_out= !rst_n? 0: data_out_r;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state<=IDLE;
	else
		state<=next_state;
end
	
//cnt1
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n )
		cnt1<=0;
	else if(tx_data_already) begin
			if(!flag1)
				cnt1<=0;
			if(flag1)
				cnt1<=cnt1+1;
	end
end
//cnt2
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n )
		cnt2<=0;
	else if(tx_data_already) begin
			if(!flag2)
				cnt2<=0;
			if(flag2)
				cnt2<=cnt2+1;
	end
end
//cnt3
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n )
		cnt3<=0;
	else if(tx_data_already) begin
			if(!flag3)
				cnt3<=0;
			if(flag3)
				cnt3<=cnt3+1;
	end
end
always@(*) begin
	case(state)
		IDLE:
			if(data_valid)
				next_state<=SEND_FRONT1;
			else
				next_state<=IDLE;
		SEND_FRONT1:
			if(front_over)
				next_state<=SEND_dATA1;
			else
				next_state<=SEND_FRONT1;
	    SEND_dATA1:
			if(data_over)
				next_state<=SEND_ENDING1;
			else
				next_state<=SEND_dATA1;
		SEND_ENDING1:
			if(ending_over) 
				next_state<=SEND_FRONT2;
			else
				next_state<=SEND_ENDING1;
		SEND_FRONT2:
			if(front_over)
				next_state<=SEND_dATA2;
			else
				next_state<=SEND_FRONT2;
		SEND_dATA2:
			if(data_over)
				next_state<=SEND_ENDING2;
			else
				next_state<=SEND_dATA2;
		SEND_ENDING2:
			if(ending_over)
				next_state<=SEND_FRONT3;
			else
				next_state<=SEND_ENDING2;
		SEND_FRONT3:
			if(front_over)
				next_state<=SEND_dATA3;
			else
				next_state<=SEND_FRONT3;
		SEND_dATA3:
			if(data_over)
				next_state<=SEND_ENDING3;
			else
				next_state<=SEND_dATA3;
		SEND_ENDING3:
			if(ending_over)
				next_state<=IDLE;
			else
				next_state<=SEND_ENDING3;
	endcase
end


always@(posedge clk) begin
	if(state==IDLE)begin
		if(data_valid) begin
			data_in_r<=data_in;
			done<=1;
			ending_over<=0;
			data_out_valid<=0;
		end
	end
	if(state==SEND_FRONT1||state==SEND_FRONT2||state==SEND_FRONT3) begin
		done<=0;
		ending_over<=0;
		if(tx_data_already) begin
			if(cnt1<157) begin
				data_out_r<=front_r[1255:1248];
				data_out_valid<=1;
				front_r<=front_r<<8;
				flag1<=1;
			end
			else begin
				front_over<=1;
				data_out_valid<=0;
				front_r<=front;
				flag1<=0;
			end
		end
   end
	if(state==SEND_dATA1) begin
		if(tx_data_already) begin
			front_over<=0;
			data_out_r<=8'b01011011;//[
			data_over<=1;
			data_out_valid<=1;
			ending_r<=ending;
		end
	end
	if(state==SEND_dATA2) begin
		front_over<=0;
		if(tx_data_already) begin
			if(cnt2<640) begin
				data_out_r<=data_in_r[5119:5112];
				data_in_r<=data_in_r<<8;
				data_out_valid<=1;
				flag2<=1;
			end
			else begin
				data_over<=1;
				flag2<=0;
				data_out_valid<=0;
				ending_r<=ending;
			end
		end
	end
	if(state==SEND_dATA3) begin
		if(tx_data_already) begin
			front_over<=0;
			data_out_r<=8'b01011101;//]
			data_over<=1;
			data_out_valid<=1;
			ending_r<=ending;
		end
	end
	if(state==SEND_ENDING1||state==SEND_ENDING2||state==SEND_ENDING3) begin
		data_over<=0;
		if(tx_data_already) begin
			if(cnt3<7) begin
				data_out_r<=ending_r[55:48];
				ending_r<=ending_r<<8;
				data_out_valid<=1;
				flag3<=1;
			end
			else begin
				ending_over<=1;
				ending_r<=ending;
				data_out_valid<=0;
				flag3<=0;
			end
		end
	end
end
endmodule				