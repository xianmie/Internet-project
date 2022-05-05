module _2_to_480(rst_n,clk,en,data_in,finish,q,data_valid);
input en;//使能信号
input[15:0] data_in;
output reg finish;//前一次串并转换完成
output reg[3839:0]q;
input clk;
input rst_n;
input data_valid;
reg [5:0]count;
reg [3839:0]data;

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==0)
    begin
       count<=0;
       finish<=1;
       data<=3839'b0;
       q<=0;
    end
    else
    begin
	 if(data_valid)
	 begin
       if(count<=240&&en)
       begin
           count<=count+1;
           finish<=0;
           data<={data[3823:0],data_in};
           q<=data[3839:0];
       end
       else
       begin
       count<=0;
       finish<=1;
       q<=0;
       end
    end
	 end
end
endmodule