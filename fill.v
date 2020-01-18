
module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,							// On Board Keys
		//LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;		
   input [9:0] SW;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	wire wEn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn,goback;
	assign writeEn = ~KEY[1];
 	assign goback = ~KEY[3];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "white.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
		
	
	datapath datapath(KEY[2], writeEn, goback, SW[3:0], SW[6:4]/*SW[9:7]*/, CLOCK_50, x, y, colour, wEn);

	
endmodule

module datapath(resetn, go, goback, spot, car, /*notice,initialpage,errorempty,erroroccupied, */clock, x, y, colour, wEn);//clock cycle
	input clock;
	input go;
	input goback;
	input resetn;
	//input initialpage;
//	input errorempty;
//	input erroroccupied;
//	input errornotfit;
//	input errorpasswordwrong;
	input [3:0] spot;
	input [2:0] car;
	//input [2:0]notice;
	output reg [7:0] x, y;
	output reg [2:0] colour;
	output reg wEn;

	
	parameter spot1 = 15'b010111101011010;
	
	wire [5:0] countX, countY;
	wire [6:0] countvanx, countvany;
	wire [7:0] countbusx,countbusy;
	wire [8:0] countemptyx,countemptyy;
	wire [8:0] countoccupiedx,countoccupiedy;
	wire [8:0] countnotfitx,countnotfity;
	wire [8:0] countwrongx,countwrongy;
	wire [15:0] countbackgroundx,countbackgroundy;
	
	wire [2:0] color,color2,color3,colorempty,coloroccupied ,colornotfit,colorwrong,colorbackground;
	wire enable, en25, enable2,enablevan,enablebus,enableempty,enableoccupied,enablenotfit,enablewrong,enablebackground;
	
	counter_ rateDiv(1'b1, clock, enable);
	assign en25 = (enable == 0)?1:0;
	
	counter_ counterX(6'd12, en25, countX);
	assign enable2 = (countX == 6'd12)?1:0;
	
	counter_ countervanx(6'd29, en25, countvanx);
	assign enablevan = (countvanx == 6'd29)? 1:0;
	
	counter_ counterbusx(7'd69,en25,countbusx);
	assign enablebus = (countbusx == 7'd69)? 1:0;
	
	counter_ counteremptyx(7'd69,en25,countemptyx);
	assign enableempty = (countemptyx ==7'd69)?1:0;
	
	counter_ counteroccupiedx(7'd69, en25,countoccupiedx);
	assign enableoccupied = (countoccupiedx ==7'd69)? 1:0;
	
	counter_ counternotfitx(7'd69, en25,countnotfitx);
	assign enablenotfit = (countnotfitx ==7'd69)? 1:0;
	
	counter_ counterwrongx(7'd69, en25,countwrongx);
	assign enablewrong = (countwrongx ==7'd69)? 1:0;
	
	counter_ counterbackground(15'd159,en25,countbackgroundx);
	assign enablebackground = (countbackgroundx ==15'd159)? 1:0;
	
	
	wire [7:0] address;
	wire [11:0] addressvan;
	wire [12:0] addressbus;
	wire [13:0] addressempty;
	wire [13:0] addressoccupied;
	wire [13:0] addressnotfit;
	wire [13:0] addresswrong;
	wire [30:0] addressbackground;
	
	
	//counter_ countTest(11'b11111111111, en25, address);
	
	counter_ counterY(6'd12, enable2, countY);
	assign address = countY*6'd13+countX;
	
	counter_ countervany(6'd14,enablevan,countvany);
	assign addressvan = countvany*6'd30+countvanx;
	
	counter_ counterbusy(7'd19,enablebus,countbusy);
	assign addressbus = countbusy*7'd70+countbusx;
	
	counter_ counteremptyy(7'd39, enableempty,countemptyy);
	assign addressempty = countemptyy *7'd70 + countemptyx;
	
	counter_ counteroccupiedy(7'd39, enableoccupied,countoccupiedy);
	assign addressoccupied = countoccupiedy *7'd70 + countoccupiedx;
	
	counter_ counternotfity(7'd39, enablenotfit,countnotfity);
	assign addressnotfit = countnotfity *7'd70 + countnotfitx;
	
	counter_ counterwrongy(7'd39, enablewrong,countwrongy);
	assign addresswrong = countwrongy *7'd70 + countwrongx;
	
	counter_ counterbackgroundy(7'd119,enablebackground,countbackgroundy);
	assign addressbackground =countbackgroundy*10'd160 +countbackgroundx;
	
	romcar256x3 car1(address, en25, color);
	romvan1024x3 van(addressvan,en25,color2);
	rom4096x3 bus(addressbus,en25,color3);
	romempty4096x3 empty (addressempty,en25,colorempty);
	romoccupied4096x3 occupied(addressoccupied, en25, coloroccupied);
	romnotfit4096x3 notfit(addressnotfit,en25,colornotfit);
	romwrong4096x3 wrong(addresswrong,en25,colorwrong);
	rombackground19200x3 background(addressbackground, en25, colorbackground);
	
	reg [7:0] regX; 
	reg [6:0] regY;
//	reg [7:0] wire1;
//	reg [6:0] wire2;
	reg [2:0] car2;
	reg goflag;
	reg gobackflag;
	//reg flagbackground;
//	reg flagerrorempty;
//	reg flagerroroccupied;
//	reg flagtest=0;
	reg flagExtra/*,flagnotice*/;
	reg flag1,flag2,flag3,flag4,flag5,flag6,flag7,flag8,flag9;
	wire [24:0] timer;
	counter_ timer3(2000000, clock, timer);
	

	
	always@(posedge clock)
	begin
//		if(initialpage==1) begin
//			flagbackground <=1;
//			if(timer==999993) 
//			 begin
//				// flagExtra<=0;
//            regX<=regX;
//			   regY<=regY;
//			 end
//		 end
//		 
//		if(initialpage==0) 
//		 begin
//			flagbackground <=0;
//		 end
//		if(flagbackground) 
//		 begin
//			colour <= colorbackground;
//			x <= regX + countbackgroundx-1;
//			y <= regY + countbackgroundy;
////			flagtest=1;
//		 end



//		 else if((!flagerrorempty) & flagtest) begin
//			colour <= 3'b111;
//			x <= countemptyx;
//			y <= countemptyy;
//		 end
//		else if((!flagerroroccupied) &  flagtest) begin
//			colour <= 3'b110;
//			x <= countemptyx;
//			y <= countemptyy;
//		 end

		   
//		 
//		 if(errorempty==1) begin
//			flagerrorempty <=1;
//			if(timer==999993) 
//			 begin
//            regX<=regX;
//			   regY<=regY;
//			 end
//		 end
//		 
//		if(errorempty==0) 
//		 begin
//			flagerrorempty <=0;
//		 end
//		if(flagerrorempty) 
//		 begin
//  			colour<=colorempty;
//			x<=countemptyx;
//			y<=countemptyy;
//		 end
		 
		 
//		 if(erroroccupied==1) begin
//			flagerroroccupied <=1;
//			if(timer==999993) 
//			 begin
//            regX<=regX;
//			   regY<=regY;
//			 end
//		 end
//		 
//		if(erroroccupied==0) 
//		 begin
//			flagerroroccupied <=0;
//		 end
//		if(flagerroroccupied) 
//		 begin
//  			colour<=coloroccupied;
//			x<=countoccupiedx;
//			y<=countoccupiedy;
//		 end
//		 


		 
		if (!resetn) begin
			regX <= 0;
			regY <= 0;
			car2 <= 3'b010;
		//	flagnotice<=1'b0;
		 end
		else if(go==1) begin
			goflag <= 1;
			wEn<=1;
			if(goback==1) begin
				gobackflag<=1;
			end
		 end

		
		else if (goflag==1) begin
			if (timer == 999993) begin
				car2 <= car;

				//if(!flagbackground) begin
				case (spot)
					4'b0000: begin
				//	flagnotice<=1'b0;
					if(gobackflag==0)
					 begin
					     flagExtra<=0;
						  
						  if (regX < 8'd71) 
						   begin
							  regX <= regX + 1'b1;
						   end
							else if (regY < 7'd14) 
							 begin
								regY <= regY + 1'b1;
							 end
							else
							 begin
								regX <= regX;
								regY <= regY;
								flag1<=1;
								goflag<=0;
								wEn<=0;
							 end
						 end
						
						else 
					    begin 
							if(flag1==1)
							 begin
								regX<=8'd71;
								regY<=7'd14;
								flag1<=0;
								flagExtra<=0;
							 end
							else
							 begin
								 if((regY>0)&(regY<=7'd14)) 
								  begin
									regY<=regY-1'b1;
								  end
								else if((regX>0)&(regX<=8'd71))
								 begin
									regX<=regX-1'b1;
								 end
								else
								 begin
									regX<=regX;
									regY<=regY;
									flagExtra<=1;
									gobackflag<=0;
									goflag<=0;
									wEn<=0;
								 end
							 end
						end
					end
					  
					4'b0001: begin
				//	flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
						if (regX < 8'd85) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if (regY < 7'd14) 
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag2 <=1;
							goflag<=0;
							wEn<=0;
							
						 end
					  end	
					
				    else 
					  begin 
						 if(flag2==1)
						  begin
							regX<=8'd85;
							regY<=7'd14;
							flag2<=0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>0)&(regY<=7'd14)) 
							  begin
								regY<=regY-1'b1;
							  end
							else if((regX>0)&(regX<=8'd85))
							 begin
								regX<=regX-1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
				   end
					4'b0010: begin
				//	flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
						if (regX < 8'd99) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if (regY < 7'd14) 
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag3<=1;
							goflag<=0;
							wEn<=0;
						   
						 end
					  end
					  
					else 
					 begin 
						 if(flag3==1)
						  begin
							regX<=8'd99;
							regY<=7'd14;
							flag3<=0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>0)&(regY<=7'd14)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd99))
							 begin
								regX<=regX-1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
						  end
						end
					end	 
					4'b0011: begin
				//	flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
						if (regX < 8'd113) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if (regY < 7'd14) 
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag4<=1;
							goflag<=0;
							wEn<=0;
							
						 end
						end
						
						else 
					    begin 
						 if(flag4==1)
						  begin
							regX <= 8'd113;
							regY <= 7'd14;
							flag4 <= 0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>0)&(regY<=7'd14)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd113))
							 begin
								regX<=regX-1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
					end	 
					4'b0100: begin
					//flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
						if (regX < 8'd127) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if (regY < 7'd14) 
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag5<=1;
							goflag<=0;
							wEn<=0;
							
						 end
						end
						else 
					    begin 
						 if(flag5==1)
						  begin
							regX<=8'd127;
							regY<=7'd14;
							flag2<=0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>0)&(regY<=7'd14)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd127))
							 begin
								regX<=regX-1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
					end	 
					4'b0101: begin
				//	flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
						if (regX < 8'd141) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if (regY < 7'd14) 
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag6 <= 1;
							goflag<=0;
							wEn<=0;
							
						 end
						end
						else 
					    begin 
						 if(flag6==1)
						  begin
							regX<=8'd141;
							regY<=7'd14;
							flag2<=0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>0)&(regY<=7'd14)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd141))
							 begin
								regX<=regX-1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
     				 end
					 4'b0110: begin //van
					// flagnotice<=1'b0;
					 if(gobackflag==0) begin
					 flagExtra<=0;
						if (regY < 7'd31) 
						 begin
						   regY <= regY + 1'b1;
						 end
						else if (regX < 8'd125) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if((regY < 7'd45) && (regY>=7'd31))
						 begin
							regY <= regY + 1'b1;
						 end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag7<=1;
							goflag<=0;
							wEn<=0;
							
						 end
					   end
						
					else 
					  begin 
						 if(flag7==1)
						  begin
							regX<=8'd125;
							regY<=7'd45;
							flag7<=0;
							flagExtra<=0;
						  end
						
						 else
						  begin
							 if((regY>7'd31)&(regY<=7'd45)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd125))
							 begin
								regX<=regX-1'b1;
							 end
							else if((regY>0) & (regY<=7'd31))
							 begin
								regY <= regY - 1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
     				 end
					 
					4'b0111: begin
					//flagnotice<=1'b0;
					if(gobackflag==0) begin
					flagExtra<=0;
					  if (regY < 7'd31) 
						 begin
						   regY <= regY + 1'b1;
						 end
						else if (regX < 8'd90) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if((regY < 7'd45) && (regY>=7'd31))
						begin
							regY <= regY + 1'b1;
						end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag8<=1;
							goflag<=0;
							wEn<=0;
							
						 end
						end
					 else 
					  begin 
						 if(flag8==1)
						  begin
							regX<=8'd90;
							regY<=7'd45;
							flag8<=0;
							flagExtra<=0;
						  end
						 else
						  begin
							 if((regY>7'd31)&(regY<=7'd45)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd90))
							 begin
								regX<=regX-1'b1;
							 end
							else if((regY>0) & (regY<=7'd31))
							 begin
								regY <= regY - 1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							 end
							end
						end
						 
     				 end
				 	4'b1000: begin //bus
					//flagnotice<=1'b0;
					if(gobackflag==0) begin
					  flagExtra<=0;
					  if (regY < 7'd63) 
						begin
						   regY <= regY + 1'b1;
						 end
						else if (regX < 8'd83) 
						 begin
							regX <= regX + 1'b1;
						 end
						else if((regY < 7'd82) && (regY>=7'd63))
						begin
							regY <= regY + 1'b1;
						end
						else
						 begin
						   regX <= regX;
							regY <= regY;
							flag9<=1;
							goflag<=0;
							wEn<=0;
							
						 end
						end
						 
					else 
					  begin 
						 if(flag9==1)
						  begin
						   flagExtra<=0;
							regX <= 8'd83;
							regY <= 7'd82;
							flag9 <= 0;
						  end
						 else
						  begin
							 if((regY>7'd63)&(regY<=7'd82)) 
							  begin
								regY<=regY-1'b1;
							 end
							else if((regX>0)&(regX<=8'd83))
							 begin
								regX<=regX-1'b1;
							 end
							else if((regY>0) & (regY<=7'd63))
							 begin
								regY <= regY - 1'b1;
							 end
							else
							 begin
								regX<=regX;
								regY<=regY;
								flagExtra<=1;
								gobackflag<=0;
								goflag<=0;
								wEn<=0;
								 
							end
						 end
     				 end
					end
					4'b1111: begin
						 regX<=regX;
						 regY<=regY;
					//	 flagnotice<=1'b1;
						 flagExtra<=1'b1;
						 end
				 endcase
				//end
			 end
			if (!flagExtra)  begin//if(!flagnotice) beginif ((!flagExtra) & (!flagnotice) ) begin
				case (car2)
					3'b000: begin
						colour <= color;
						x <= regX + countX;
						y <= regY + countY;
					 end
					3'b001: begin
						colour <= color2;
						x <= regX + countvanx;
						y <= regY + countvany;
					 end
					3'b011: begin
					  colour <= color3;
					  x <= regX + countbusx;
					  y <= regY + countbusy;
					  end
					default: begin
						colour <= 3'b111;
						x <= regX + countemptyx;
						y <= regY + countemptyy;
					  end
				 endcase
				  

			end
				
				
//			  else if  (flagnotice == 1) begin
//				case (notice)
//					3'b000: begin
//						colour<=colorempty;
//						x<=regX+countemptyx;
//						y<=regY+countemptyy;
//						end
//					3'b001: begin
//						colour<=coloroccupied;
//						x<=regX+countoccupiedx;
//						y<=regY+countoccupiedy;
//						end
//					3'b010:begin
//					   colour<=colornotfit;
//						x<=regX+countnotfitx;
//						y<=regY+countnotfity;
//						end
//					3'b011:begin
//					   colour<=colorwrong;
//						x<=regX+countwrongx;
//						y<=regY+countwrongy;
//						end
//					default: begin
//						colour <= 3'b111;
//						x <= regX + countemptyx;
//						y <= regY + countemptyy;
//					  end
//				 endcase
//			  end
			  else
				begin
					colour <= 3'b111;
					x <=  regX+countemptyx;
					y <=  regY+countemptyy;
				end
			 end	
		else if(/*!flagbackground & */flagExtra)
		 begin
			colour <= 3'b111;
			x <= countemptyx;
			y <= countemptyy;
		 end
	end	
endmodule 
	

module counter_(count, clock, q);
	input [24:0] count;
	input clock;
	output reg [24:0] q;
	
	always@(posedge clock)
	 begin
		if (q >= count)
			q <= 0;
		else
			q <= q + 1;
	 end
endmodule


	

