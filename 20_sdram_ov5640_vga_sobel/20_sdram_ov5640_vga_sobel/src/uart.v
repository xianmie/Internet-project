
module uart(
	input                        clk,
	input                        rst_n,
	input                        uart_rx,
	output                       uart_tx,
	input								  echo,
	input								  loc_val,
	input[12:0]						  distance,
	input[11:0]						  location_x,
	input[11:0]						  location_y
);

parameter                        CLK_FRE = 50;//Mhz
localparam                       IDLE 		=  0;
localparam                       SELECT 	=  1;//choose if the picture is still, make sure that location sends every time it needs
localparam                       LOCSEND 	=  2;//location sending
localparam								SRSEND 	=  3;//HC-SR04 distance sending

reg										loc_val_delay;
reg										echo_delay;
wire										nege_echo;
wire[15:0]								distance_bcd;
wire[15:0]								location_x_bcd;
wire[15:0]								location_y_bcd;
wire										dis_bcd_val;
wire										loc_x_bcd_val;
wire										loc_y_bcd_val;
reg [3:0]								dis_one;
reg [3:0]								dis_ten;
reg [3:0]								dis_hun;
reg [3:0]								dis_thd;
reg [3:0]								loc_x_one;
reg [3:0]								loc_x_ten;
reg [3:0]								loc_x_hun;
reg [3:0]								loc_y_one;
reg [3:0]								loc_y_ten;
reg [3:0]								loc_y_hun;
reg[7:0]                         tx_data;
reg[7:0]                         tx_str;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
wire[7:0]                        rx_data;
wire                             rx_data_valid;
wire                             rx_data_ready;
reg[3:0]                         state;

assign rx_data_ready = 1'b1;//always can receive data,
							
assign nege_echo = echo_delay & ~echo;
//assign dis_one	=	(dis_bcd_val==1'b1)? distance_bcd[3:0]:dis_one;
//assign dis_ten	=	(dis_bcd_val==1'b1)? distance_bcd[7:4]:dis_ten;
//assign dis_hun	=	(dis_bcd_val==1'b1)? distance_bcd[11:8]:dis_hun;
//assign loc_one	=	(loc_bcd_val==1'b1)? location_bcd[3:0]:loc_one;
//assign loc_ten	=	(loc_bcd_val==1'b1)? location_bcd[7:4]:loc_ten;
//assign loc_hun	=	(loc_bcd_val==1'b1)? location_bcd[11:8]:loc_hun;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		dis_one <= 4'd0;
		dis_ten <= 4'd0;
		dis_hun <= 4'd0;
		dis_thd <= 4'd0;
		loc_x_one <= 4'd0;
		loc_x_ten <= 4'd0;
		loc_x_hun <= 4'd0;
	end
	else if(loc_x_bcd_val==1'b1)
	begin
		loc_x_one <= location_x_bcd[3:0];
		loc_x_ten <= location_x_bcd[7:4];
		loc_x_hun <= location_x_bcd[11:8];
	end
	else if(dis_bcd_val==1'b1)
	begin
		dis_one <= distance_bcd[3:0];
		dis_ten <= distance_bcd[7:4];
		dis_hun <= distance_bcd[11:8];
		dis_thd <= distance_bcd[15:12];
	end
	else
	begin
		dis_one <= dis_one;
		dis_ten <= dis_ten;
		dis_hun <= dis_hun;
		dis_thd <= dis_thd;
		loc_x_one <= loc_x_one;
		loc_x_ten <= loc_x_ten;
		loc_x_hun <= loc_x_hun;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		loc_y_one <= 4'd0;
		loc_y_ten <= 4'd0;
		loc_y_hun <= 4'd0;
	end
	else if(loc_y_bcd_val==1'b1)
	begin
		loc_y_one <= location_y_bcd[3:0];
		loc_y_ten <= location_y_bcd[7:4];
		loc_y_hun <= location_y_bcd[11:8];
	end
	else
	begin
		loc_y_one <= loc_y_one;
		loc_y_ten <= loc_y_ten;
		loc_y_hun <= loc_y_hun;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			if(loc_val==1'b1)
				state <= SELECT;
			else if(dis_bcd_val==1'b1)
			begin
				state <= SRSEND;
				tx_cnt <= 8'd20;
			end
			else
				state <= IDLE;
		SELECT:
		begin
			if(loc_val_delay==1'b1 && location_y==12'd0)
			begin
				state <= IDLE;
			end
			else if(loc_val_delay==1'b1 && location_y > 12'd0)
			begin
				state <= LOCSEND;
				tx_cnt <= 8'd0;
			end
			else
				state <= SELECT;
		end
		LOCSEND:
		begin
			tx_data <= tx_str;
			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd19)//Send 19 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)//last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= SELECT;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		SRSEND:
		begin
			tx_data <= tx_str;
			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd38)//Send 19 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)//last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= IDLE;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		default:
			state <= IDLE;
	endcase
end

//combinational logic
always@(*)
begin
	case(tx_cnt)
		8'd0 :  tx_str <= "L";
		8'd1 :  tx_str <= "o";
		8'd2 :  tx_str <= "c";
		8'd3 :  tx_str <= "a";
		8'd4 :  tx_str <= "t";
		8'd5 :  tx_str <= "i";
		8'd6 :  tx_str <= "o";
		8'd7 :  tx_str <= "n";
		8'd8 :  tx_str <= ":";
		8'd9:   tx_str <= "(";
		8'd10 : tx_str <= loc_x_hun+48;
		8'd11:  tx_str <= loc_x_ten+48;
		8'd12:  tx_str <= loc_x_one+48;
		8'd13:  tx_str <= ",";
		8'd14:  tx_str <= loc_y_hun+48;
		8'd15:  tx_str <= loc_y_ten+48;
		8'd16:  tx_str <= loc_y_one+48;
		8'd17:  tx_str <= ")";
		8'd18:  tx_str <= "\r";
		8'd19:  tx_str <= "\n";
		8'd20:  tx_str <= "D";
		8'd21:  tx_str <= "i";
		8'd22:  tx_str <= "s";
		8'd23:  tx_str <= "t";
		8'd24:  tx_str <= "a";
		8'd25:  tx_str <= "n";
		8'd26:  tx_str <= "c";
		8'd27:  tx_str <= "e";
		8'd28:  tx_str <= ":";
		8'd29:  tx_str <= " ";
		8'd30:  tx_str <= dis_thd+48;
		8'd31:  tx_str <= ".";
		8'd32:  tx_str <= dis_hun+48;
		8'd33:  tx_str <= dis_ten+48;
		8'd34:  tx_str <= dis_one+48;
		8'd35:  tx_str <= " ";
		8'd36:  tx_str <= "m";
		8'd37:  tx_str <= "\r";
		8'd38:  tx_str <= "\n";
		default:tx_str <= 8'd0;
	endcase
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		loc_val_delay <= 1'b0;
		echo_delay <= 1'b0;
	end
	else
	begin
		loc_val_delay <= loc_val;
		echo_delay <= echo;
	end
end

bin2bcd_13 bcd_m0(
	.clk								 (clk								),
	.nrst								 (rst_n							),
	.start							 (nege_echo						),
	.bin								 (distance						),
	.bcd								 (distance_bcd					),
	.valid							 (dis_bcd_val					)
);

bin2bcd_12 bcd_m1(
	.clk								  (clk							),
	.nrst								  (rst_n							),
	.start							  (loc_val_delay				),
	.bin								  (location_x					),
	.bcd								  (location_x_bcd				),
	.valid							  (loc_x_bcd_val				)
);

bin2bcd_12 bcd_m2(
	.clk									(clk							),
	.nrst									(rst_n						),
	.start								(loc_val_delay				),
	.bin									(location_y					),
	.bcd									(location_y_bcd			),
	.valid								(loc_y_bcd_val				)
);

uart_rx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(115200)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  )
);

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(115200)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);
endmodule