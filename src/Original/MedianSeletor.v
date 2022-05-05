module MedianSeletor (
	input                       rst_n,
	input                       pclk,
	input                       ycbcr_hs,
	input                       ycbcr_vs,
	input                       ycbcr_de,
	input[7:0]                  data_in,
	output[7:0]             	 data_out,
	output                      median_hs,
	output                      median_vs,
	output                      median_de
	
);
reg  [7:0]  Data1,Data2,Data3;
reg  [7:0]  Data4,Data5,Data6;
reg  [7:0]  Data7,Data8,Data9;
wire [7:0]  p1,p2,p3;

reg [7:0]Max1;
reg [7:0]Max2;
reg [7:0]Max3;

reg [7:0]Med1;
reg [7:0]Med2;
reg [7:0]Med3;

reg [7:0]Min1;
reg [7:0]Min2;
reg [7:0]Min3;

reg [7:0]Min_of_Max;
reg [7:0]Med_of_Med;
reg [7:0]Max_of_Min;

reg [7:0]Median;

reg [8:0] hs_buf ;
reg [8:0] vs_buf ;
reg [8:0] de_buf ;

linebuffer_Wapper#
(
	.no_of_lines(3),
	.samples_per_line(640),
	.data_width(8)
)
 linebuffer_Wapper_m0(
	.ce         (1'b1   ),
	.wr_clk     (pclk   ),
	.wr_en      (ycbcr_de   ),
	.wr_rst     (~rst_n   ),
	.data_in    (data_in),
	.rd_en      (ycbcr_de   ),
	.rd_clk     (pclk   ),
	.rd_rst     (~rst_n   ),
	.data_out   ({p3,p2,p1}  )
   );
always@(posedge pclk)
begin
	Data1 <= p1;
	Data4 <= p2;
	Data7 <= p3;
	
	Data2 <= Data1;
	Data5 <= Data4;
	Data8 <= Data7;
	
	Data3 <= Data2;
	Data6 <= Data5;
	Data9 <= Data8;
end

always@(posedge pclk or negedge rst_n)
if(!rst_n)
begin
Max1 <= 8'd0;
Max2 <= 8'd0;
Max3 <= 8'd0;

Med1 <= 8'd0;
Med2 <= 8'd0;
Med3 <= 8'd0;

Min1 <= 8'd0;
Min2 <= 8'd0;
Min3 <= 8'd0;

Min_of_Max <= 8'd0;
Med_of_Med <= 8'd0;
Max_of_Min <= 8'd0;

Median <= 8'd0;
end
else
begin
//找到各行最大值
//第一行
if(Data1 >= Data2 && Data1 >= Data3)
Max1 <= Data1;
else if(Data2 >= Data1 && Data2 >= Data3)
Max1 <= Data2;
else if(Data3 >= Data1 && Data3 >= Data2)
Max1 <= Data3;
//第二行
if(Data4 >= Data5 && Data4 >= Data6)
Max2 <= Data4;
else if(Data5 >= Data4 && Data5 >= Data6)
Max2 <= Data5;
else if(Data6 >= Data4 && Data6 >= Data5)
Max2 <= Data6;
//第三行
if(Data7 >= Data8 && Data7 >= Data9)
Max3 <= Data7;
else if(Data8 >= Data7 && Data8 >= Data9)
Max3 <= Data8;
else if(Data9 >= Data7 && Data9 >= Data8)
Max3 <= Data9;

//找到各行中值
//第一行
if((Data1 >= Data2 && Data1 <= Data3) || (Data1 >= Data3 && Data1 <= Data2))
Med1 <= Data1;
else if((Data2 >= Data1 && Data2 <= Data3) || (Data2 >= Data3 && Data2 <= Data1))
Med1 <= Data2;
else if((Data3 >= Data1 && Data3 <= Data2) || (Data3 >= Data2 && Data3 <= Data1))
Med1 <= Data3;
//第二行
if((Data4 >= Data5 && Data4 <= Data6) || (Data4 >= Data6 && Data4 <= Data5))
Med2 <= Data4;
else if((Data5 >= Data4 && Data5 <= Data6) || (Data5 >= Data6 && Data5 <= Data4))
Med2 <= Data5;
else if((Data6 >= Data4 && Data6 <= Data5) || (Data6 >= Data5 && Data6 <= Data4))
Med2 <= Data6;
//第三行
if((Data7 >= Data8 && Data7 <= Data9) || (Data7 >= Data9 && Data7 <= Data8))
Med3 <= Data7;
else if((Data8 >= Data7 && Data8 <= Data9) || (Data8 >= Data9 && Data8 <= Data7))
Med3 <= Data8;
else if((Data9 >= Data7 && Data9 <= Data8) || (Data9 >= Data8 && Data9 <= Data7))
Med3 <= Data9;

//找到各行最小值
//第一行
if(Data1 <= Data2 && Data1 <= Data3)
Min1 <= Data1;
else if(Data2 <= Data1 && Data2 <= Data3)
Min1 <= Data2;
else if(Data3 <= Data1 && Data3 <= Data2)
Min1 <= Data3;
//第二行
if(Data4 <= Data5 && Data4 <= Data6)
Min2 <= Data4;
else if(Data5 <= Data4 && Data5 <= Data6)
Min2 <= Data5;
else if(Data6 <= Data4 && Data6 <= Data5)
Min2 <= Data6;
//第三行
if(Data7 <= Data8 && Data7 <= Data9)
Min3 <= Data7;
else if(Data8 <= Data7 && Data8 <= Data9)
Min3 <= Data8;
else if(Data9 <= Data7 && Data9 <= Data8)
Min3 <= Data9;


//找到最大值列的最小值
if(Max1 <= Max2 && Max1 <= Max3)
Min_of_Max <= Max1;
else if(Max2 <= Max1 && Max2 <= Max3)
Min_of_Max <= Max2;
else if(Max3 <= Max1 && Max3 <= Max2)
Min_of_Max <= Max3;

//找到中值列的中值
if((Med1 >= Med2 && Med1 <= Med3) || (Med1 >= Med3 && Med1 <= Med2))
Med_of_Med <= Med1;
else if((Med2 >= Med1 && Med2 <= Med3) || (Med2 >= Med3 && Med2 <= Med1))
Med_of_Med <= Med2;
else if((Med3 >= Med1 && Med3 <= Med2) || (Med3 >= Med2 && Med3 <= Med1))
Med_of_Med <= Med3;

//找到最小值列的最大值
if(Min1 >= Min2 && Min1 >= Min3)
Max_of_Min <= Min1;
else if(Min2 >= Min1 && Min2 >= Min3)
Max_of_Min <= Min2;
else if(Min3 >= Min1 && Min3 >= Min2)
Max_of_Min <= Min3;

//找到三行三列的全体中值
if((Min_of_Max >= Med_of_Med && Min_of_Max <= Max_of_Min) || (Min_of_Max >= Max_of_Min && Min_of_Max <= Med_of_Med))
Median <= Min_of_Max;
else if((Med_of_Med >= Min_of_Max && Med_of_Med <= Max_of_Min) || (Med_of_Med >= Max_of_Min && Med_of_Med <= Min_of_Max))
Median <= Med_of_Med;
else if((Max_of_Min >= Min_of_Max && Max_of_Min <= Med_of_Med) || (Max_of_Min >= Med_of_Med && Max_of_Min <= Min_of_Max))
Median <= Max_of_Min;

end


//hs vs de delay 9 clock
always@(posedge pclk or negedge rst_n)
begin
  if (!rst_n)
  begin
    hs_buf <= 9'd0 ;
    vs_buf <= 9'd0 ;
    de_buf <= 9'd0 ;
  end
  else
  begin
    hs_buf <= {hs_buf[7:0], ycbcr_hs} ;
	 vs_buf <= {vs_buf[7:0], ycbcr_vs} ;
	 de_buf <= {de_buf[7:0], ycbcr_de} ;
  end
end

assign median_hs = hs_buf[8] ;
assign median_vs = vs_buf[8] ;
assign median_de = de_buf[8] ;
assign data_out  = Median;
	 
endmodule