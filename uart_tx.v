//删掉din_vld 和rdy信号之后，只需要把计数器cnt0计数条件改为add_cnt0 = 1,就可以了
`timescale 1ns / 1ps
	
module uart_tx(
                 input             clk    ,			
                 input             rst_n  ,		
                 input [7:0]       din    ,
                 input             din_vld,	 //开始发送信号，如果你要一直发送可以删掉此信号，本人是从模块中剪下来的代码，懒得删改了
                 output reg        rdy    ,  //类似接收的完成信号，表示完成了一个字节的传输，同din_vld信号一样，不要可以删掉
                 output reg        dout   
             );

parameter         BPS    = 5208;

reg   [7:0]       tx_data_tmp;	

reg               flag_add   ;
reg   [14:0]      cnt0       ;
wire              add_cnt0   ;
wire              end_cnt0   ;

reg   [ 3:0]      cnt1       ;
wire              add_cnt1   ;
wire              end_cnt1   ;

wire  [ 9:0]      data       ;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(flag_add==0 && din_vld)begin
        flag_add <= 1;
    end
    else if(end_cnt1)begin
        flag_add <= 0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1;
    end
end

assign add_cnt0 = flag_add;
assign end_cnt0 = add_cnt0 && cnt0==BPS-1 ;

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1==10-1 ;


always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		tx_data_tmp <=8'd0;
	end
	else if(flag_add==1'b0 && din_vld) begin	
		tx_data_tmp <= din;	
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		dout <= 1'b1;
	end
	else if(add_cnt0 && cnt0==1-1)begin
        dout<= data[cnt1];
    end 
end

assign  data = {1'b1,tx_data_tmp,1'b0}; //传输时是从低到高 data = {停止位，数据[7],数据[6] ~ 数据[0],起始位};

always  @(*)begin
    if(din_vld || flag_add)
        rdy = 1'b0;
    else
        rdy = 1'b1;
end

endmodule
