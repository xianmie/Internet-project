module transform_base64 ( input clk,
                          input rst_n,
								  input[479:0] data_in,
								  output [639:0] data_out);
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
     data_insert={2'b0,data_in[479:474],2'b0,data_in[473:468],2'b0,data_in[467:462],2'b0,data_in[461:456],2'b0,data_in[455:450],2'b0,data_in[449:444],2'b0,data_in[443:438],2'b0,data_in[437:432],
	              2'b0,data_in[431:426],2'b0,data_in[425:420],2'b0,data_in[419:414],2'b0,data_in[413:408],2'b0,data_in[407:402],2'b0,data_in[401:396],2'b0,data_in[395:390],2'b0,data_in[389:384],
	              2'b0,data_in[383:378],2'b0,data_in[377:372],2'b0,data_in[371:366],2'b0,data_in[365:360],2'b0,data_in[359:354],2'b0,data_in[353:348],2'b0,data_in[347:342],2'b0,data_in[341:336],
	              2'b0,data_in[335:330],2'b0,data_in[329:324],2'b0,data_in[323:318],2'b0,data_in[317:312],2'b0,data_in[311:306],2'b0,data_in[305:300],2'b0,data_in[299:294],2'b0,data_in[293:288],
	              2'b0,data_in[287:282],2'b0,data_in[281:276],2'b0,data_in[275:270],2'b0,data_in[269:264],2'b0,data_in[263:258],2'b0,data_in[257:252],2'b0,data_in[251:246],2'b0,data_in[245:240],
	              2'b0,data_in[239:234],2'b0,data_in[233:228],2'b0,data_in[227:222],2'b0,data_in[221:216],2'b0,data_in[215:210],2'b0,data_in[209:204],2'b0,data_in[203:198],2'b0,data_in[197:192],
	              2'b0,data_in[191:186],2'b0,data_in[185:180],2'b0,data_in[179:174],2'b0,data_in[173:168],2'b0,data_in[167:162],2'b0,data_in[161:156],2'b0,data_in[155:150],2'b0,data_in[149:144],
	              2'b0,data_in[143:138],2'b0,data_in[137:132],2'b0,data_in[131:126],2'b0,data_in[125:120],2'b0,data_in[119:114],2'b0,data_in[113:108],2'b0,data_in[107:102],2'b0,data_in[101:96],
	              2'b0,data_in[95:90],2'b0,data_in[89:84],2'b0,data_in[83:78],2'b0,data_in[77:72],2'b0,data_in[71:66],2'b0,data_in[65:60],2'b0,data_in[59:54],2'b0,data_in[53:48],
				  2'b0,data_in[47:42],2'b0,data_in[41:36],2'b0,data_in[35:30],2'b0,data_in[29:24],2'b0,data_in[23:18],2'b0,data_in[17:12],2'b0,data_in[11:6],2'b0,data_in[5:0]
				 };
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

rom_base64	rom_base64_inst4 (
	.address ( data_insert[39:32] ),
	.clock ( clk ),
	.q ( data_out_w[39:32] )
	);
	
rom_base64	rom_base64_inst5 (
	.address ( data_insert[47:40] ),
	.clock ( clk ),
	.q ( data_out_w[47:40] )
	);
	
rom_base64	rom_base64_inst6 (
	.address ( data_insert[55:48] ),
	.clock ( clk ),
	.q ( data_out_w[55:48] )
	);
	
rom_base64	rom_base64_inst7 (
	.address ( data_insert[63:56] ),
	.clock ( clk ),
	.q ( data_out_w[63:56] )
	);
rom_base64	rom_base64_inst8 (
	.address ( data_insert[71:64] ),
	.clock ( clk ),
	.q ( data_out_w[71:64] )
	);
	
rom_base64	rom_base64_inst9 (
	.address ( data_insert[79:72] ),
	.clock ( clk ),
	.q ( data_out_w[79:72] )
	);
	
rom_base64	rom_base64_inst10 (
	.address ( data_insert[87:80] ),
	.clock ( clk ),
	.q ( data_out_w[87:80] )
	);
	
rom_base64	rom_base64_inst11 (
	.address ( data_insert[95:88] ),
	.clock ( clk ),
	.q ( data_out_w[95:88] )
	);

rom_base64	rom_base64_inst12 (
	.address ( data_insert[103:96] ),
	.clock ( clk ),
	.q ( data_out_w[103:96] )
	);
	
rom_base64	rom_base64_inst13 (
	.address ( data_insert[111:104] ),
	.clock ( clk ),
	.q ( data_out_w[111:104] )
	);
	
rom_base64	rom_base64_inst14 (
	.address ( data_insert[119:112] ),
	.clock ( clk ),
	.q ( data_out_w[119:112] )
	);
	
rom_base64	rom_base64_inst15 (
	.address ( data_insert[127:120] ),
	.clock ( clk ),
	.q ( data_out_w[127:120] )
	);

rom_base64	rom_base64_inst16 (
	.address ( data_insert[135:128] ),
	.clock ( clk ),
	.q ( data_out_w[135:128] )
	);
	
rom_base64	rom_base64_inst17 (
	.address ( data_insert[143:136] ),
	.clock ( clk ),
	.q ( data_out_w[143:136] )
	);
	
rom_base64	rom_base64_inst18 (
	.address ( data_insert[151:144] ),
	.clock ( clk ),
	.q ( data_out_w[151:144] )
	);
	
rom_base64	rom_base64_inst19 (
	.address ( data_insert[159:152] ),
	.clock ( clk ),
	.q ( data_out_w[159:152] )
	);
rom_base64	rom_base64_inst20 (
	.address ( data_insert[167:160] ),
	.clock ( clk ),
	.q ( data_out_w[167:160] )
	);
	
rom_base64	rom_base64_inst21 (
	.address ( data_insert[175:168] ),
	.clock ( clk ),
	.q ( data_out_w[175:168] )
	);
	
rom_base64	rom_base64_inst22 (
	.address ( data_insert[183:176] ),
	.clock ( clk ),
	.q ( data_out_w[183:176] )
	);
	
rom_base64	rom_base64_inst23 (
	.address ( data_insert[191:184] ),
	.clock ( clk ),
	.q ( data_out_w[191:184] )
	);
	
rom_base64	rom_base64_inst24 (
	.address ( data_insert[199:192] ),
	.clock ( clk ),
	.q ( data_out_w[199:192] )
	);
	
rom_base64	rom_base64_inst25 (
	.address ( data_insert[207:200] ),
	.clock ( clk ),
	.q ( data_out_w[207:200] )
	);
	
rom_base64	rom_base64_inst26 (
	.address ( data_insert[215:208] ),
	.clock ( clk ),
	.q ( data_out_w[215:208] )
	);
	
rom_base64	rom_base64_inst27 (
	.address ( data_insert[223:216] ),
	.clock ( clk ),
	.q ( data_out_w[223:216] )
	);

rom_base64	rom_base64_inst28 (
	.address ( data_insert[231:224] ),
	.clock ( clk ),
	.q ( data_out_w[231:224] )
	);
	
rom_base64	rom_base64_inst29 (
	.address ( data_insert[239:232] ),
	.clock ( clk ),
	.q ( data_out_w[239:232] )
	);
	
rom_base64	rom_base64_inst30 (
	.address ( data_insert[ 247:240] ),
	.clock ( clk ),
	.q ( data_out_w[ 247:240] )
	);
	
rom_base64	rom_base64_inst31 (
	.address ( data_insert[255:248] ),
	.clock ( clk ),
	.q ( data_out_w[255:248] )
	);

rom_base64	rom_base64_inst32 (
	.address ( data_insert[263:256] ),
	.clock ( clk ),
	.q ( data_out_w[263:256] )
	);
	
rom_base64	rom_base64_inst33 (
	.address ( data_insert[271:264] ),
	.clock ( clk ),
	.q ( data_out_w[271:264] )
	);
	
rom_base64	rom_base64_inst34 (
	.address ( data_insert[279:272] ),
	.clock ( clk ),
	.q ( data_out_w[279:272] )
	);
	
rom_base64	rom_base64_inst35 (
	.address ( data_insert[287:280] ),
	.clock ( clk ),
	.q ( data_out_w[287:280] )
	);

rom_base64	rom_base64_inst36 (
	.address ( data_insert[295:288] ),
	.clock ( clk ),
	.q ( data_out_w[295:288] )
	);
	
rom_base64	rom_base64_inst37 (
	.address ( data_insert[303:296] ),
	.clock ( clk ),
	.q ( data_out_w[303:296] )
	);
	
rom_base64	rom_base64_inst38 (
	.address ( data_insert[311:304] ),
	.clock ( clk ),
	.q ( data_out_w[311:304] )
	);
	
rom_base64	rom_base64_inst39 (
	.address ( data_insert[319:312] ),
	.clock ( clk ),
	.q ( data_out_w[319:312] )
	);
	
rom_base64	rom_base64_inst40 (
	.address ( data_insert[327:320] ),
	.clock ( clk ),
	.q ( data_out_w[327:320] )
	);
	
rom_base64	rom_base64_inst41 (
	.address ( data_insert[335:328] ),
	.clock ( clk ),
	.q ( data_out_w[335:328] )
	);
	
rom_base64	rom_base64_inst42 (
	.address ( data_insert[343:336] ),
	.clock ( clk ),
	.q ( data_out_w[343:336] )
	);
	
rom_base64	rom_base64_inst43 (
	.address ( data_insert[351:344] ),
	.clock ( clk ),
	.q ( data_out_w[351:344] )
	);

rom_base64	rom_base64_inst44 (
	.address ( data_insert[359:352] ),
	.clock ( clk ),
	.q ( data_out_w[359:352] )
	);
	
rom_base64	rom_base64_inst45 (
	.address ( data_insert[367:360] ),
	.clock ( clk ),
	.q ( data_out_w[367:360] )
	);
	
rom_base64	rom_base64_inst46 (
	.address ( data_insert[375:368] ),
	.clock ( clk ),
	.q ( data_out_w[375:368] )
	);
	
rom_base64	rom_base64_inst47 (
	.address ( data_insert[383:376] ),
	.clock ( clk ),
	.q ( data_out_w[383:376] )
	);
	
rom_base64	rom_base64_inst48 (
	.address ( data_insert[391:384] ),
	.clock ( clk ),
	.q ( data_out_w[391:384] )
	);
	
rom_base64	rom_base64_inst49 (
	.address ( data_insert[399:392] ),
	.clock ( clk ),
	.q ( data_out_w[399:392] )
	);
	
rom_base64	rom_base64_inst50 (
	.address ( data_insert[407:400] ),
	.clock ( clk ),
	.q ( data_out_w[407:400] )
	);
	
rom_base64	rom_base64_inst51 (
	.address ( data_insert[415:408] ),
	.clock ( clk ),
	.q ( data_out_w[415:408] )
	);

rom_base64	rom_base64_inst52 (
	.address ( data_insert[423:416] ),
	.clock ( clk ),
	.q ( data_out_w[423:416] )
	);
	
rom_base64	rom_base64_inst53 (
	.address ( data_insert[431:424] ),
	.clock ( clk ),
	.q ( data_out_w[431:424] )
	);
	
rom_base64	rom_base64_inst54 (
	.address ( data_insert[439:432] ),
	.clock ( clk ),
	.q ( data_out_w[439:432] )
	);
	
rom_base64	rom_base64_inst55 (
	.address ( data_insert[447:440 ] ),
	.clock ( clk ),
	.q ( data_out_w[447:440 ] )
	);
	
rom_base64	rom_base64_inst56 (
	.address ( data_insert[455:448 ] ),
	.clock ( clk ),
	.q ( data_out_w[455:448 ] )
	);
	
rom_base64	rom_base64_inst57 (
	.address ( data_insert[463:456 ] ),
	.clock ( clk ),
	.q ( data_out_w[463:456 ] )
	);
	
rom_base64	rom_base64_inst58 (
	.address ( data_insert[471:464 ] ),
	.clock ( clk ),
	.q ( data_out_w[471:464 ] )
	);
	
rom_base64	rom_base64_inst59 (
	.address ( data_insert[479:472 ] ),
	.clock ( clk ),
	.q ( data_out_w[479:472 ] )
	);

rom_base64	rom_base64_inst60 (
	.address ( data_insert[487:480] ),
	.clock ( clk ),
	.q ( data_out_w[487:480] )
	);
	
rom_base64	rom_base64_inst61 (
	.address ( data_insert[495:488 ] ),
	.clock ( clk ),
	.q ( data_out_w[495:488 ] )
	);
	
rom_base64	rom_base64_inst62 (
	.address ( data_insert[503:496 ] ),
	.clock ( clk ),
	.q ( data_out_w[503:496 ] )
	);
	
rom_base64	rom_base64_inst63 (
	.address ( data_insert[511:504 ] ),
	.clock ( clk ),
	.q ( data_out_w[511:504 ] )
	);
	
rom_base64	rom_base64_inst64 (
	.address ( data_insert[519:512 ] ),
	.clock ( clk ),
	.q ( data_out_w[519:512 ] )
	);
	
rom_base64	rom_base64_inst65 (
	.address ( data_insert[527:520 ] ),
	.clock ( clk ),
	.q ( data_out_w[527:520 ] )
	);
	
rom_base64	rom_base64_inst66 (
	.address ( data_insert[535:528 ] ),
	.clock ( clk ),
	.q ( data_out_w[535:528 ] )
	);
	
rom_base64	rom_base64_inst67 (
	.address ( data_insert[543:536 ] ),
	.clock ( clk ),
	.q ( data_out_w[543:536 ] )
	);
	
rom_base64	rom_base64_inst68 (
	.address ( data_insert[551:544 ] ),
	.clock ( clk ),
	.q ( data_out_w[551:544 ] )
	);
	
rom_base64	rom_base64_inst69 (
	.address ( data_insert[559:552 ] ),
	.clock ( clk ),
	.q ( data_out_w[559:552 ] )
	);

rom_base64	rom_base64_inst70 (
	.address ( data_insert[567:560 ] ),
	.clock ( clk ),
	.q ( data_out_w[567:560 ] )
	);	

rom_base64	rom_base64_inst71 (
	.address ( data_insert[575:568 ] ),
	.clock ( clk ),
	.q ( data_out_w[575:568 ] )
	);

rom_base64	rom_base64_inst72 (
	.address ( data_insert[583:576 ] ),
	.clock ( clk ),
	.q ( data_out_w[583:576 ] )
	);

rom_base64	rom_base64_inst73 (
	.address ( data_insert[591:584 ] ),
	.clock ( clk ),
	.q ( data_out_w[591:584 ] )
	);

rom_base64	rom_base64_inst74 (
	.address ( data_insert[599:592 ] ),
	.clock ( clk ),
	.q ( data_out_w[599:592 ] )
	);
	
rom_base64	rom_base64_inst75 (
	.address ( data_insert[607:600 ] ),
	.clock ( clk ),
	.q ( data_out_w[607:600 ] )
	);
	
rom_base64	rom_base64_inst76 (
	.address ( data_insert[615:608 ] ),
	.clock ( clk ),
	.q ( data_out_w[615:608 ] )
	);
	
rom_base64	rom_base64_inst77 (
	.address ( data_insert[623:616 ] ),
	.clock ( clk ),
	.q ( data_out_w[623:616 ] )
	);
	
rom_base64	rom_base64_inst78 (
	.address ( data_insert[631:624 ] ),
	.clock ( clk ),
	.q ( data_out_w[631:624 ] )
	);
	
rom_base64	rom_base64_inst79 (
	.address ( data_insert[639:632 ] ),
	.clock ( clk ),
	.q ( data_out_w[639:632 ] )
	);

endmodule