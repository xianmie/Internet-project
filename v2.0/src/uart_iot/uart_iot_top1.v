module uart_iot_top1(
			input clk,
			input rst_n,
			input en,
			input[15:0] data_in,
			input data_valid,
			output finish_to480,
			output tx
);
wire[3839:0] q;
wire finish_transform;
wire[5119:0] transform_data_out;
wire tx_data_already;
wire[7:0] at_data_out;
wire data_out_valid;
wire at_read;

_2_to_480 m1(rst_n,clk,en,data_in,finish_to480,q,data_valid);
transform m2(clk,rst_n,finish_to480,q,at_read,finish_transform,transform_data_out);
at_tx m3( clk,	rst_n,transform_data_out,finish_transform,tx_data_already,at_data_out,at_read,data_out_valid);
uart_tx m4(clk, rst_n, at_data_out,data_out_valid,tx_data_already, tx);

endmodule