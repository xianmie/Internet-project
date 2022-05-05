
module frame_read_sdram_lot
#(
	parameter MEM_DATA_BITS          = 32,  //external memory user interface data width
	parameter ADDR_BITS              = 23,  //external memory user interface address width
	parameter BUSRT_BITS             = 10,  //external memory user interface burst width 位宽
	parameter BURST_SIZE             = 128  //burst size
)
(
	input                            rst,
	input                            mem_clk,                             // external memory controller user interface clock
	input                            uart_oneframe_done,
	output reg                       rd_burst_req,                        // to external memory controller,send out a burst read request
	output reg[BUSRT_BITS - 1:0]     rd_burst_len,                        // to external memory controller,data length of the burst read request, not bytes
	output reg[ADDR_BITS - 1:0]      rd_burst_addr,                       // to external memory controller,base address of the burst read request 
	input                            rd_burst_data_valid,                 // from external memory controller,read data valid 
	input[MEM_DATA_BITS - 1:0]       rd_burst_data,                       // from external memory controller,read request data
	input                            rd_burst_finish,                     // from external memory controller,burst read finish
   output reg[1:0]                  frame_readcnt,
	output reg[14:0]                 frame_block_cnt,
	output reg                       uart_oneframe_start,
	input                            write_allframe_done
);
//state machine code
localparam IDLE                      = 3'd0;
localparam MEM_READ1                  = 3'd1;  //read state
localparam MEM_READ2                 =3'd2;
localparam WAIT_UARTEND               = 3'd3;  //write state

localparam ONE                       = 256'd1; //256 bit '1' , ONE[n-1:0] for n bit '1'
localparam ZERO                      = 256'd0; //256 bit '0'


reg[23:0]          base_addr;
reg[23:0]          shifting_addr;
reg[2:0]           state;

always@(posedge mem_clk or posedge rst)
begin
if(rst ==1'b1)
begin
base_addr<=24'd0;
frame_readcnt<=2'b00;
end
else
begin
if(frame_block_cnt<=15'd1280)
begin
base_addr<=24'd0;
if(frame_block_cnt==15'd1280)
frame_readcnt<=2'b01;
end
else if(frame_block_cnt>15'd1280 &&frame_block_cnt<=15'd2560)
begin
base_addr<=24'd2073600;
if(frame_block_cnt==15'd2560)
frame_readcnt<=2'b10; 
end
else
begin 
base_addr<=24'd4147200;
if(frame_block_cnt==15'd3840)
frame_readcnt<=2'b11;
end
end
end

//main
always@(posedge mem_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		state <= IDLE;
		rd_burst_req <= 1'b0;
		rd_burst_len <= BURST_SIZE[BUSRT_BITS - 1:0];
		rd_burst_addr <= ZERO[ADDR_BITS - 1:0]; // rd_burst_addr <= 0;
		uart_oneframe_start<=1'b0;
		shifting_addr<=23'd0;
		frame_block_cnt<=15'd0;
	end
	else
	begin
		case(state)
			IDLE:
			begin
			if(write_allframe_done==1'b1 && uart_oneframe_done==1'b1)  
			begin
			   state <= MEM_READ1;
				rd_burst_req <= 1'b1;
				rd_burst_len <= BURST_SIZE[BUSRT_BITS - 1:0]; //突发读长度固定128byte
				if(shifting_addr < 23'd307200) 
				shifting_addr <=shifting_addr+23'd240;
				else 
				shifting_addr<=23'd0;
				
				rd_burst_addr<=base_addr+shifting_addr;//地址改变
				
			end
			
			end
			MEM_READ1:
			begin
		      if(rd_burst_data_valid == 1'b1) //利用该信号作为使能控制串转并工作
				rd_burst_req <= 1'b0;
				
				if(rd_burst_finish == 1'b1)
				begin
				rd_burst_addr <= rd_burst_addr + BURST_SIZE[ADDR_BITS - 1:0];
				rd_burst_req <= 1'b1;
			   rd_burst_len <= BURST_SIZE[BUSRT_BITS - 1:0];
				state<=MEM_READ2;
				end
		   end
				
			MEM_READ2:
			begin
				if(rd_burst_data_valid == 1'b1)
					rd_burst_req <= 1'b0;
					
				if(rd_burst_finish == 1'b1)
				begin
				state<=WAIT_UARTEND;
				frame_block_cnt<=frame_block_cnt+1'b1; //block 计数1280个为一帧
				state<=WAIT_UARTEND;
				end
			end
			
			WAIT_UARTEND:
			begin
			uart_oneframe_start<=1'b1;
			 if(uart_oneframe_done==1'b1)  
			 begin
			 uart_oneframe_start<=1'b0 ;    
			 state<=IDLE;
			 end
			end
			
			default:
				state <= IDLE;
		  endcase
	end
end

endmodule