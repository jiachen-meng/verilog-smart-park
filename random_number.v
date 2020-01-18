module random_number(input CLOCK_50, output reg[9:0]PASSWORD); //this module generates a random number
//which wil be used as the password provided to user
//it will be stored in each spot's datapath and/or datapath
   wire [9:0] Q;
	ratecounter_2 rate_counter(CLOCK_50, Q);
	always @ (*) begin /////////////////////////NEED TO FIX
//		
	PASSWORD [9:0] <= Q [9:0];
//		
	end
endmodule


module ratecounter_2(input clock, output reg [9:0]Q); //this will generate a "random" number in 10 bits binary
	always @(posedge clock) begin
		if (Q == 10'b1111111111)
			Q <= 10'b0;
		else
			Q <= Q + 10'b1;
	end
	
endmodule
