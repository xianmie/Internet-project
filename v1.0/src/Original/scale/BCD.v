module BCD(
	input [11:0]	binary,
	output reg[3:0] hun,
	output reg[3:0] ten,
	output reg[3:0] one,
	output reg[3:0] dot
);

	integer i;
	
	always@(binary)
	begin
	
		hun = 4'd0;
		ten = 4'd0;
		one = 4'd0;
		dot = 4'd0;
		
		for(i=11;i>=0;i=i-1)
		begin
			
			if(hun >= 5)
				hun = hun +3;
			if(ten >= 5)
				ten = ten +3;
			if(one >= 5)
				one = one +3;
			if(dot >= 5)
				dot = dot +3;
				
			hun = hun << 1;
			hun[0] = ten[3];
			ten = ten << 1;
			ten[0] = one[3];
			one = one << 1;
			one[0] = dot[3];
			dot = dot << 1;
			dot[0] = binary[i];
			
		end
	
	end
	
endmodule
