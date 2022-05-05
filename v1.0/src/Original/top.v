module top(
	input                       clk,
	input                       rst_n,
	input								 switch,					 //camera_switch
	input								 key3,					 //num_rst_n
	//camera of frame_processing
	inout                       cmos_scl_1,          //cmos i2c clock
	inout                       cmos_sda_1,          //cmos i2c data
	input                       cmos_vsync_1,        //cmos vsync
	input                       cmos_href_1,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
	output                      cmos_xclk_1,         //cmos externl clock
	input   [7:0]               cmos_db_1,           //cmos data
	input                       cmos_rst_n_1,        //cmos reset
	output                      cmos_pwdn_1,         //cmos power down
	//camera of scale
	inout                       cmos_scl_2,          //cmos i2c clock
	inout                       cmos_sda_2,          //cmos i2c data
	input                       cmos_vsync_2,        //cmos vsync
	input                       cmos_href_2,         //cmos hsync refrence,data valid
//	input                       cmos_pclk_2,         //cmos pxiel clock
	output                      cmos_xclk_2,         //cmos externl clock
	input   [7:0]               cmos_db_2,           //cmos data
	input                       cmos_rst_n_2,        //cmos reset
	output                      cmos_pwdn_2,         //cmos power down
	//camera of rightside
	inout                       cmos_scl_3,          //cmos i2c clock
	inout                       cmos_sda_3,          //cmos i2c data
	input                       cmos_vsync_3,        //cmos vsync
	input                       cmos_href_3,         //cmos hsync refrence,data valid
//	input                       cmos_pclk_3,         //cmos pxiel clock
	output                      cmos_xclk_3,         //cmos externl clock
	input   [7:0]               cmos_db_3,           //cmos data
	input                       cmos_rst_n_3,        //cmos reset
	output                      cmos_pwdn_3,         //cmos power down
	
	output                      vga_out_hs,        //vga horizontal synchronization
	output                      vga_out_vs,        //vga vertical synchronization
	output[4:0]                 vga_out_r,         //vga red
	output[5:0]                 vga_out_g,         //vga green
	output[4:0]                 vga_out_b,         //vga blue
	output                      sdram_clk,         //sdram clock
	output                      sdram_cke,         //sdram clock enable
	output                      sdram_cs_n,        //sdram chip select
	output                      sdram_we_n,        //sdram write enable
	output                      sdram_cas_n,       //sdram column address strobe
	output                      sdram_ras_n,       //sdram row address strobe
	output[1:0]                 sdram_dqm,         //sdram data enable
	output[1:0]                 sdram_ba,          //sdram bank address
	output[12:0]                sdram_addr,        //sdram address
	inout[15:0]                 sdram_dq,          //sdram data
	output[5:0]						 seg_sel,			  //seg 
   output[7:0]						 seg_data,			  //seg data
	output							 buzzer				  //alert
);
parameter MEM_DATA_BITS          = 16;             //external memory user interface data width
parameter ADDR_BITS              = 24;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire									  clk_24M;
wire									  clk_96M;
wire                            ext_mem_clk;       //external memory clock, 100MHz
wire                            video_clk;         //video pixel clock, 74.25MHz
wire                            hs;
wire                            vs;
wire                            de;
wire[11:0]							  h_active_cnt;
wire[11:0]							  v_active_cnt;
wire[15:0]                      vout_data;

wire				cmos_rgb_vsync;
wire				cmos_rgb_href;
wire				cmos_vsync;
wire				cmos_href;
//wire				cmos_pclk;
wire				cmos_xclk;
wire				cmos_pwdn;
wire				cmos_rst_n;
wire[7:0]		cmos_db;

wire[23:0]                      cmos_24bit_data;
wire                            cmos_24bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire                            initial_en;
wire                            Config_Done;
wire[7:0]                       ycbcr_y;
wire[7:0]                       ycbcr_cb;
wire                            ycbcr_hs;
wire                            ycbcr_vs;
wire                            ycbcr_de;
wire                            sobel_hs;
wire                            sobel_vs;
wire                            sobel_de;
wire[7:0]                       sobel_out;
wire[7:0]							  median_1_out;
wire									  median_1_hs;
wire									  median_1_vs;
wire									  median_1_de;
wire[7:0]							  median_out;
wire									  median_hs;
wire									  median_vs;
wire									  median_de;
wire									  erode_1_hs;
wire									  erode_1_vs;
wire									  erode_1_de;
wire									  erode_1_data;
wire									  erode_hs;
wire									  erode_vs;
wire									  erode_de;
wire									  erode_data;
wire									  dilate_1_hs;
wire									  dilate_1_vs;
wire									  dilate_1_de;
wire									  dilate_1_data;
wire									  dilate_hs;
wire									  dilate_vs;
wire									  dilate_de;
wire									  dilate_data;
reg 									  vga_out_hs_reg;
reg 									  vga_out_vs_reg;
reg 									  vga_out_de_reg;
reg [15:0]							  vga_out_data_reg;
wire									  vga_1_hs;
wire									  vga_1_vs;
wire									  vga_1_de;
wire[15:0]							  vga_1_data;
wire									  vga_2_hs;
wire									  vga_2_vs;
wire									  vga_2_de;
wire[15:0]							  vga_2_data;
wire									  vga_3_hs;
wire									  vga_3_vs;
wire									  vga_3_de;
wire[15:0]							  vga_3_data;
wire[5:0]							  seg_sel_2;
wire[7:0]							  seg_data_2;
wire[5:0]							  seg_sel_3;
wire[7:0]							  seg_data_3;
wire[23:0]							  vout_24bit;
wire[7:0]								cmos_frame_Gray;

assign vga_1_hs 	= dilate_1_hs;
assign vga_1_vs 	= dilate_1_vs;
assign vga_1_de 	= dilate_1_de;
assign vga_1_data	= dilate_1_data==1'b0 ? 16'd0:16'hffff;

assign seg_sel = (camera_index==2'b11)? seg_sel_3:seg_sel_2;
assign seg_data = (camera_index==2'b11)? seg_data_3:seg_data_2;

assign vga_out_hs = vga_out_hs_reg;
assign vga_out_vs = vga_out_vs_reg;
assign vga_out_de = vga_out_de_reg;
assign vga_out_r  = (vga_out_de_reg == 1'b1) ? vga_out_data_reg[4:0] : 5'd0;
assign vga_out_g  = (vga_out_de_reg == 1'b1) ? vga_out_data_reg[10:5] : 6'd0;
assign vga_out_b  = (vga_out_de_reg == 1'b1) ? vga_out_data_reg[15:11] : 5'd0;


assign sdram_clk = ext_mem_clk;
assign write_en = cmos_frame_href;
assign write_data = {cmos_frame_Gray[7:3],cmos_frame_Gray[7:2],cmos_frame_Gray[7:3]};
assign cmos_24bit_wr = cmos_rgb_href;

//camera

reg[1:0]	camera_index;
wire		switch_posedge;

ax_debounce ax_debounce_m0(
		.clk						(clk),
		.rst						(~rst_n),
		.button_in				(switch),
		.button_posedge		(switch_pose),
		.button_negedge		(),
		.button_out				()
);

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		camera_index <= 2'b00;
	else if(switch_pose==1'b1)
		camera_index <= camera_index + 1;
	else
		;
end

reg		cmos_vsync_reg;
reg		cmos_href_reg;
reg[7:0]	cmos_db_reg;
reg		cmos_rst_n_reg;
reg[10:0]sobel_threshold;

assign	cmos_vsync = cmos_vsync_reg;
assign	cmos_href = cmos_href_reg;
assign	cmos_db = cmos_db_reg;
assign	cmos_rst_n = cmos_rst_n_reg;

always@(*)
begin
	if(camera_index==2'b01)
	begin
		cmos_vsync_reg <= cmos_vsync_1;
		cmos_href_reg <= cmos_href_1;
		cmos_db_reg <= cmos_db_1;
		cmos_rst_n_reg <= cmos_rst_n_1;
		sobel_threshold <= 11'd3;
		
		vga_out_hs_reg <= vga_1_hs;
		vga_out_vs_reg <= vga_1_vs;
		vga_out_de_reg <= vga_1_de;
		vga_out_data_reg <= vga_1_data;
		
	end
	else if(camera_index==2'b10)
	begin
		cmos_vsync_reg <= cmos_vsync_2;
		cmos_href_reg <= cmos_href_2;
		cmos_db_reg <= cmos_db_2;
		cmos_rst_n_reg <= cmos_rst_n_2;
		sobel_threshold <= 11'd3;
		
		vga_out_hs_reg <= vga_2_hs;
		vga_out_vs_reg <= vga_2_vs;
		vga_out_de_reg <= vga_2_de;
		vga_out_data_reg <= vga_2_data;
		
	end
	else if(camera_index==2'b11)
	begin
		cmos_vsync_reg <= cmos_vsync_3;
		cmos_href_reg <= cmos_href_3;
		cmos_db_reg <= cmos_db_3;
		cmos_rst_n_reg <= cmos_rst_n_3;
		sobel_threshold <= 11'd80;
		
		vga_out_hs_reg <= vga_3_hs;
		vga_out_vs_reg <= vga_3_vs;
		vga_out_de_reg <= vga_3_de;
		vga_out_data_reg <= vga_3_data;
		
	end
	else
	begin
		cmos_vsync_reg <= cmos_vsync_1;
		cmos_href_reg <= cmos_href_1;
		cmos_db_reg <= cmos_db_1;
		cmos_rst_n_reg <= cmos_rst_n_1;
		sobel_threshold <= 11'd3;
		
		vga_out_hs_reg <= vga_1_hs;
		vga_out_vs_reg <= vga_1_vs;
		vga_out_de_reg <= vga_1_de;
		vga_out_data_reg <= vga_1_data;
		
	end
end

assign	cmos_xclk_1 = cmos_xclk;
assign	cmos_xclk_2 = cmos_xclk;
assign	cmos_xclk_3 = cmos_xclk;
assign	cmos_pwdn_1 = cmos_pwdn;
assign	cmos_pwdn_2 = cmos_pwdn;
assign	cmos_pwdn_3 = cmos_pwdn;

//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (clk_24M                  ),
	.c1                         (ext_mem_clk              )
	);
//generate video pixel clock
sys_pll_2 sys_pll_m1(
	.inclk0                     (clk		                  ),
	.c0                         (video_clk						)
	);
	


parameter  SLAVE_ADD = 7'b1001_000     ;  //slave  address         90  
parameter  BIT_CTRL   = 1'b0           ;  //OV7725的字节地址为8位  0:8位 1:16位
parameter  DATA_CTRL  = 1'b1           ;  //OV7725的数据为8位  0:8位 1:16位
parameter  CLK_FREQ   = 26'd50_000_000 ;  //i2c_dri模块的驱动时钟频率 50.0MHz
parameter  I2C_FREQ   = 18'd250_000    ;  //I2C的SCL时钟频率,不超过400KHz

wire					i2c_exec_1;
wire					i2c_done_1;
wire[7:0]	 		i2c_addr_1;
wire[15:0] 			i2c_wr_data_1;
wire					i2c_config_done_1;
wire					sys_init_done;
wire					dri_clk_1;

wire					i2c_exec_2;
wire					i2c_done_2;
wire[7:0]	 		i2c_addr_2;
wire[15:0] 			i2c_wr_data_2;
wire					i2c_config_done_2;
wire					dri_clk_2;

wire					i2c_exec_3;
wire					i2c_done_3;
wire[7:0]	 		i2c_addr_3;
wire[15:0] 			i2c_wr_data_3;
wire					i2c_config_done_3;
wire					dri_clk_3;


assign  sys_init_done = i2c_config_done_1;

//assign	cmos_rst_n  = 1'b1;		//cmos work state (50us delay)
assign	cmos_pwdn   = 1'b0;		//cmos power on

//camera_1                   					                                					                                   					                    
i2c_cfg  u_i2c_cfg_m1(
                   .clk          (dri_clk_1),
                   .rst_n        (rst_n & ~switch_pose),
                   .i2c_done     (i2c_done_1),
                   .i2c_exec     (i2c_exec_1),
                   .i2c_addr     (i2c_addr_1),
                   .i2c_wr_data  (i2c_wr_data_1),                
                   .cfg_done     (i2c_config_done_1)
                   );

//I2C驱动模块
i2c_dri #(
    .SLAVE_ADDR         (SLAVE_ADD),    //参数传递
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  ) 
    )
u_i2c_dr_m1(
    .clk                (clk),
    .rst_n              (rst_n & ~switch_pose     ),

    .i2c_exec           (i2c_exec_1  ),   
    .bit_ctrl           (BIT_CTRL  ),   
    .data_ctrl          (DATA_CTRL),
    .i2c_rh_wl          (0),            //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr           ({8'b0,i2c_addr_1}),   
    .i2c_data_w         (i2c_wr_data_1),   
    .i2c_data_r         (),   
    .i2c_done           (i2c_done_1  ),    
    .scl                (cmos_scl_1   ),   
    .sda                (cmos_sda_1   ),   
    .dri_clk            (dri_clk_1)       //I2C操作时钟
    );

	 
//camera_2
i2c_cfg  u_i2c_cfg_m2(
                   .clk          (dri_clk_2),
                   .rst_n        (rst_n & ~switch_pose),
                   .i2c_done     (i2c_done_2),
                   .i2c_exec     (i2c_exec_2),
                   .i2c_addr     (i2c_addr_2),
                   .i2c_wr_data  (i2c_wr_data_2),                
                   .cfg_done     (i2c_config_done_2)
                   );

//I2C驱动模块
i2c_dri #(
    .SLAVE_ADDR         (SLAVE_ADD),    //参数传递
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  ) 
    )
u_i2c_dr_m2(
    .clk                (clk),
    .rst_n              (rst_n  & ~switch_pose    ),

    .i2c_exec           (i2c_exec_2  ),   
    .bit_ctrl           (BIT_CTRL  ),   
    .data_ctrl          (DATA_CTRL),
    .i2c_rh_wl          (0),            //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr           ({8'b0,i2c_addr_2}),   
    .i2c_data_w         (i2c_wr_data_2),   
    .i2c_data_r         (),   
    .i2c_done           (i2c_done_2  ),    
    .scl                (cmos_scl_2   ),   
    .sda                (cmos_sda_2   ),   
    .dri_clk            (dri_clk_2)       //I2C操作时钟
    );

	 
//camera_3
i2c_cfg  u_i2c_cfg_m3(
                   .clk          (dri_clk_3),
                   .rst_n        (rst_n & ~switch_pose),
                   .i2c_done     (i2c_done_3),
                   .i2c_exec     (i2c_exec_3),
                   .i2c_addr     (i2c_addr_3),
                   .i2c_wr_data  (i2c_wr_data_3),                
                   .cfg_done     (i2c_config_done_3)
                   );

//I2C驱动模块
i2c_dri #(
    .SLAVE_ADDR         (SLAVE_ADD),    //参数传递
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  ) 
    )
u_i2c_dr_m3(
    .clk                (clk),
    .rst_n              (rst_n  & ~switch_pose    ),

    .i2c_exec           (i2c_exec_3  ),   
    .bit_ctrl           (BIT_CTRL  ),   
    .data_ctrl          (DATA_CTRL),
    .i2c_rh_wl          (0),            //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr           ({8'b0,i2c_addr_3}),   
    .i2c_data_w         (i2c_wr_data_3),   
    .i2c_data_r         (),   
    .i2c_done           (i2c_done_3  ),    
    .scl                (cmos_scl_3   ),   
    .sda                (cmos_sda_3   ),   
    .dri_clk            (dri_clk_3)       //I2C操作时钟
    );
	 

//图像采集顶层模块
  cmos_capture_raw_gray	
#(
	.CMOS_FRAME_WAITCNT		(4'd10)				//Wait n fps for steady(OmniVision need 10 Frame)
)
cmos_capture_raw_gray
(
	//global clock
	.clk_cmos				(clk_24M),						//24MHz CMOS Driver clock input
	.rst_n					(rst_n),					//global reset

	//CMOS Sensor Interface
	.cmos_pclk				(cmos_pclk),  			//24MHz CMOS Pixel clock input
	.cmos_xclk				(cmos_xclk),						//24MHz drive clock
	.cmos_data				(cmos_db),			//8 bits cmos data input
	.cmos_vsync				(cmos_vsync),			//L: vaild, H: invalid
	.cmos_href				(cmos_href),			//H: vaild, L: invalid
	
	//CMOS SYNC Data output
	.cmos_frame_vsync		(cmos_frame_vsync),	//cmos frame data vsync valid signal
	.cmos_frame_href		(cmos_frame_href),	//cmos frame data href vaild  signal
	.wr_data		         (cmos_frame_Gray),	        	//cmos frame gray output 
	.cmos_frame_clken		(data_valid),			//cmos frame data output/capture enable clock
	
	//user interface
	.cmos_fps_rate			()							//cmos image output rate
);   
   

RAW8_RGB888
#(
	.IMG_HDISP		(11'd640),
	.IMG_VDISP		(11'd480)
)
u_RAW8_RGB888
(
	//global clock
	.clk								(cmos_pclk),					//37.125MHz CMOS Pixel clock input
	.rst_n							(rst_n),
	
	//RAW input
	.per_frame_vsync				(cmos_frame_vsync),
	.per_frame_href				(cmos_frame_href),
	.per_img_RAW					(cmos_frame_Gray),			//8 bit Gray RAW data input
	
	//RGB output
	.post_frame_vsync				(cmos_rgb_vsync),				//RGB vsync
	.post_frame_href				(cmos_rgb_href),				//RGB href
	.post_img_red					(cmos_24bit_data[23:16]),	//24 bit RGB
	.post_img_green				(cmos_24bit_data[15:8]),
	.post_img_blue					(cmos_24bit_data[7:0])
);








//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_rgb_vsync           ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);
//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                ),
	.h_active_cnt					 (h_active_cnt					),
	.v_active_cnt					 (v_active_cnt					)
);

//Gray trans
rgb_to_ycbcr rgb_to_ycbcr_m0(
	.clk                        (video_clk                ),
	.rst                        (~rst_n                   ),
	.rgb_r                      ({vout_data[15:11],3'd0}  ),
	.rgb_g                      ({vout_data[10:5],2'd0}   ),
	.rgb_b                      ({vout_data[4:0],3'd0}    ),
	.rgb_hs                     (hs                       ),
	.rgb_vs                     (vs                       ),
	.rgb_de                     (de                       ),
	.ycbcr_y                    (ycbcr_y                  ),
	.ycbcr_cb                   (ycbcr_cb                 ),
	.ycbcr_cr                   (                         ),
	.ycbcr_hs                   (ycbcr_hs                 ),
	.ycbcr_vs                   (ycbcr_vs                 ),
	.ycbcr_de                   (ycbcr_de                 )
);
//MedianSeletor used to reduce noise
MedianSeletor median_m0(
	.rst_n							(rst_n							),
	.pclk								(video_clk						),
	.ycbcr_hs						(ycbcr_hs						),
	.ycbcr_vs						(ycbcr_vs						),
	.ycbcr_de						(ycbcr_de						),
	.data_in							(ycbcr_y							),
	.data_out						(median_1_out					),
	.median_hs						(median_1_hs					),
	.median_vs						(median_1_vs					),
	.median_de						(median_1_de					)
);


MedianSeletor median_m1(
	.rst_n							(rst_n							),
	.pclk								(video_clk						),
	.ycbcr_hs						(median_1_hs					),
	.ycbcr_vs						(median_1_vs					),
	.ycbcr_de						(median_1_de					),
	.data_in							(median_1_out					),
	.data_out						(median_out						),
	.median_hs						(median_hs						),
	.median_vs						(median_vs						),
	.median_de						(median_de						)
);

//Sobel
sobel sobel_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (video_clk                ),
	.threshold                  (sobel_threshold          ),
	.ycbcr_hs                   (median_hs                ),
	.ycbcr_vs                   (median_vs                ),
	.ycbcr_de                   (median_de                ),
	.data_in                    (median_out               ),
	.data_out						 (sobel_out 					),
	.sobel_dout                 (sobel_data               ),
	.sobel_hs                   (sobel_hs                 ),
	.sobel_vs                   (sobel_vs                 ),
	.sobel_de                   (sobel_de                 )
);


//Erode_rightside
erode erode_m0(
	.rst_n							(rst_n							),
	.pclk								(video_clk						),
	.sobel_hs						(sobel_hs						),
	.sobel_vs						(sobel_vs						),
	.sobel_de						(sobel_de						),
	.sobel_din						(sobel_data						),
	.erode_hs						(erode_1_hs						),
	.erode_vs						(erode_1_vs						),
	.erode_de						(erode_1_de						),
	.erode_dout						(erode_1_data						)
);

//Dilate_frameprocessing
dilate dilate_m0 (
	.rst_n							(rst_n							),
	.pclk								(video_clk						),
	.erode_hs						(sobel_hs						),
	.erode_vs						(sobel_vs						),
	.erode_de						(sobel_de						),
	.erode_din						(sobel_data						),
	.dilate_hs						(dilate_1_hs					),
	.dilate_vs						(dilate_1_vs					),
	.dilate_de						(dilate_1_de					),
	.dilate_dout					(dilate_1_data					)
);

//Dilate_rightside
dilate dilate_m1 (
	.rst_n							(rst_n							),
	.pclk								(video_clk						),
	.erode_hs						(erode_1_hs						),
	.erode_vs						(erode_1_vs						),
	.erode_de						(erode_1_de						),
	.erode_din						(erode_1_data					),
	.dilate_hs						(dilate_hs						),
	.dilate_vs						(dilate_vs						),
	.dilate_de						(dilate_de						),
	.dilate_dout					(dilate_data					)
);




//scale 

mark mark_scale(
	.clk								(video_clk						),
	.clk_50M							(clk								),
	.rst								(~rst_n							),
	.hs								(ycbcr_hs						),
	.vs								(ycbcr_vs						),
	.de								(ycbcr_de						),
	.h_cnt							(h_active_cnt					),
	.v_cnt							(v_active_cnt					),
	.ycbcr_y							(ycbcr_y							),
	.vga_data						(vga_2_data						),
	.vga_hs							(vga_2_hs						),
	.vga_vs							(vga_2_vs						),
	.vga_de							(vga_2_de						),
	.seg_sel							(seg_sel_2						),
	.seg_data						(seg_data_2						)
);


//rightside

mark_2 mark_rightside(
	.clk								(video_clk						),
	.rst								(~rst_n							),
	.num_rst_n						(key3 							),
	.hs								(dilate_hs						),
	.vs								(dilate_vs						),
	.de								(dilate_de						),
	.h_cnt							(h_active_cnt					),
	.v_cnt							(v_active_cnt					),
	.dilate							(dilate_data					),
	.vga_data						(vga_3_data						),
	.vga_hs							(vga_3_hs						),
	.vga_vs							(vga_3_vs						),
	.vga_de							(vga_3_de						),
	.seg_sel							(seg_sel_3						),
	.seg_data						(seg_data_3						),
	.buzzer							(buzzer_3						)
);




























//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (camera_index        ),
	.read_len                   (24'd307200               ), //frame size
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (camera_index         ),
	.write_len                  (24'd307200               ), //frame size
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
//sdram controller
sdram_core sdram_core_m0
(
	.rst                        (~rst_n                   ),
	.clk                        (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.sdram_cke                  (sdram_cke                ),
	.sdram_cs_n                 (sdram_cs_n               ),
	.sdram_ras_n                (sdram_ras_n              ),
	.sdram_cas_n                (sdram_cas_n              ),
	.sdram_we_n                 (sdram_we_n               ),
	.sdram_dqm                  (sdram_dqm                ),
	.sdram_ba                   (sdram_ba                 ),
	.sdram_addr                 (sdram_addr               ),
	.sdram_dq                   (sdram_dq                 )
);


endmodule