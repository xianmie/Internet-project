module to_json( input clk;
                input rst_n;
				input start_the_file;
				input prepared;//输入值已准备好
				input [63:0] rgb565_data;//3个像素点
				output [7:0] data_out;
				output finish_3pixel;//3个像素点转换完
				output finish_view;//此视角数据已转换完
                output finish_the_file;
				)
				
reg[7:0] state;
reg finish_3pixel_r;
reg finish_view_r;
reg finish_the_file_r;
reg[63:0] data_in;
reg[7:0]data_out_r;
reg[2:0]cnt1;//记view_start正在发第几个字符
reg[3:0]cnt2;//记send_data正在发第几byte
reg[1:0]cnt3;//记view_end正在发第几个字符
reg[16:0]cnt4;//记转换完了3*几个点
reg view_start_over;
reg view_end_over;
reg the_view_end;
reg[1:0] view;//正在传输的视角

localparam IDLE=0;
localparam START=1;
localparam START_VIEW=2;
localparam SEND_DATA=3;
localparam VIEW_END=4;
localparam END=5;
localparam N_3PIXEL=102400;//480*640/3

assign  data_out=(!rst_n)? 0:data_out_r;
assign  finish_3pixel=(!rst_n)? 0:finish_3pixel_r;
assign  finish_view=(!rst_n)? 0:finish_view_r;
assign	finish_the_file=(!rst_n)? 0:finish_the_file_r;

			
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			cnt1<=3'b0;
			cnt2<=4'b0;
			cnt3<=2'b0;
			cnt4<=17'b0;
			data_out_r<=8'b0;
			data_in<=64'b0;
			view_start_over<=0;
			view_end_over<=0
			the_view_end<=0;
			view<=0;
			finish_3pixel_r<=0;
			finish_r<=0;
			finish_the_file_r<=0;
			state<=IDLE;
		end
	else
	begin
	    state<=next_state;
		data_in<=rgb565_data;
	end
end
always@(posedge finish_3pixel)
begin
	if(cnt4<N_3PIXEL-1)
		cnt4<=cnt4+1;
	else
	begin
		the_view_end<=1;
		cnt4<=0;
	end
end
always@(posedge the_view_end)
begin
	if(view<2'b11)
		view<=view+1;
	else
		view<=2'b0;
end
always@(*)
begin
    case(state)
		IDLE:
			if(start_the_file&&state==IDLE)
			begin
				next_state<=START;
				view<=2'b01;
			end
			else
			        next_state<=IDLE;
	    START:
		    if(prepared)
				next_state<=START_VIEW
			else
				next_state<=START;
		START_VIEW:
			if(view_start_over)
				next_state<=SEND_DATA;
			else
			    next_state<=START_VIEW;
		SEND_DATA:
			if(finish_view_r)
				cnt3<=0;
				next_state<=VIEW_END;
			else
				next_state<=SEND_DATA;
		VIEW_END:
			if(view_end_over)
				if(view==2'b11)
					next_state<=END;
				else
					next_state<=START_VIEW;
			else
				next_state<=VIEW_END;
		END:next_state<=IDLE;
		default:next_state<=IDLE;
end

always@(posedge clk)
begin
		if(state==START)
		begin
			data_out_r<=8'b01111011;//{
			finish_the_file_r<=0;
		end
		if(state==START_VIEW)
		begin
			the_view_end<=0;
			finish_view_r<=0;
			if(cnt1==3'b000||3'b010)
			begin
				view_start_over<=0;
				data_out_r<=8'b00100010;//"
				cnt1<=cnt1+3'b001;
			end 
			if(cnt1==3'b001)
			begin
				if(view==2'b01)
					data_out_r<=8'b00110001;//1
				if(view==2'b10)
					data_out_r<=8'b00110010;//2
				if(view==2'b11)
					data_out_r<=8'b00110011;//3
				cnt1<=cnt1+3'b001;
			end
			if(cnt1==3'b011)
			begin
				data_out_r<=8'00111010;//:
				cnt1<=cnt1+3'b001;
			end
			if(cnt1==3'b100)
			begin
				data_out_r<=8'b00100010;//"
				cnt1<=0;
				view_start_over<=1;
			end
		end
		if(state==SEND_DATA)
			if(prepared)
				if(cnt2<8)
				begin
					finish_3pixel_r<=0;
					data_out_r<=data_in[63:56];
					data_in<<8;
					cnt2<=cnt2+4'b1;
				end
				else
				begin
					cnt2<=4'b0;
					finish_3pixel_r<=1;	
					if(the_view_end)
						finish_view_r<=1;
				end
			end
		end
		if(state==VIEW_END)
		begin
			view_end_over<=0;
		    if(cnt3==2'b00)
			begin
				data_out_r<=8'b00100010;//"
				cnt3<=2'b01;
			end
			if(view!=2'b11)
				if(cnt1==2'b01)
				begin
					data_out_r<=8'b00101100;//,
					cnt3<=2'b10;
				end
				if(cnt==2'b10)
				begin
					data_out_r<=8'b00001010;//\n
					cnt3<=2'b0;
					view_end_over<=1;
				end
			else
				view_end_over<=1;
		end
		if(state==END)
		begin
			data_out_r<=8'b01111101;//}
			finish_the_file_r<=1;
		end
end
endmodule