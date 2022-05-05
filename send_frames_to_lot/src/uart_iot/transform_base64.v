module transform_base64 ( input clk,
                          input rst_n,
								  input[23:0] data_in,
								  output [31:0] data_out);
reg[639:0] data_insert;
reg finish_flag;
wire[639:0] data_out_w;

assign data_out=(!rst_n)? 0: data_out_w;

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) 
     begin
	    data_insert<=630'b0;
	  end
  else
     data_insert={2'b0,data_in[23:18],2'b0,data_in[17:12],2'b0,data_in[11:6],2'b0,data_in[5:0]};
end

rom_base64	rom_base64_inst0 (
	.address ( data_insert[7:0] ),
	.clock ( clk ),
	.q ( data_out_w[7:0] )
	);
	
rom_base64	rom_base64_inst1 (
	.address ( data_insert[15:8] ),
	.clock ( clk ),
	.q ( data_out_w[15:8] )
	);
	
rom_base64	rom_base64_inst2 (
	.address ( data_insert[23:16] ),
	.clock ( clk ),
	.q ( data_out_w[23:16] )
	);
	
rom_base64	rom_base64_inst3 (
	.address ( data_insert[31:24] ),
	.clock ( clk ),
	.q ( data_out_w[31:24] )
	);


endmodule