module i2c_cfg(
               input                clk         ,
               input                rst_n       ,
               input                i2c_done    ,
               output  reg          i2c_exec    ,
               output  reg   [7:0]  i2c_addr    ,
               output  reg  [15:0]  i2c_wr_data , 
               output  reg          cfg_done       
               );
//parameter define    
parameter  DELAY_MAX = 8'hff ;
parameter  ROW_NUM = 16'd480;
parameter  COL_NUM = 16'd640; 

//reg define 
reg   [7:0]  delay_cnt   ;
reg          delay_done  ;
reg   [3:0]  cfg_cnt     ;

//*****************************************************
//**                    main code
//*****************************************************   

always @(posedge clk or negedge rst_n)
  begin
  	if(rst_n==1'b0) begin
  		delay_cnt <= 1'b0 ;
  		delay_done <= 1'b0 ;
  	end
  	else begin
  		delay_done <= 1'b0 ;
  		if(i2c_done) begin
  			delay_cnt <= 1'b0 ;
  		end	
  		else if(delay_cnt<DELAY_MAX) begin
  			delay_cnt <= delay_cnt +1'b1 ;
  			if(delay_cnt==DELAY_MAX-1'b1) begin
  				delay_done <= 1'b1 ;
  			end	
  		end
  	end
  end			

always @(posedge clk or negedge rst_n)
  begin
  	if(rst_n==1'b0) begin
  		i2c_exec <= 1'b0;
  		i2c_addr <= 1'b0;
  		i2c_wr_data <= 1'b0;
  		cfg_done <= 1'b0;
  		cfg_cnt <= 1'b0;
  	end
  	else begin
  		i2c_exec <= 1'b0;
  		if(cfg_done==1'b0) begin
  			if(delay_done) begin
  				cfg_cnt <= cfg_cnt + 1'b1;
  				if(cfg_cnt=='d2) begin
  					cfg_done <= 1'b1;
  				end	
  				case(cfg_cnt)
  					4'd0 : begin
  						       i2c_exec <= 1'b1;
  						       i2c_addr <= 8'h03;//03
  						       i2c_wr_data <= ROW_NUM;
  						     end
  					4'd1 : begin
  						       i2c_exec <= 1'b1;
  						       i2c_addr <= 8'h04;
  						       i2c_wr_data <= COL_NUM;
  						     end	 						     					     						      						         
  					default : ;
  				endcase		     
  			end	
  		end	
  	end
  end			          		    	     	  	      
                             	 	 
endmodule




