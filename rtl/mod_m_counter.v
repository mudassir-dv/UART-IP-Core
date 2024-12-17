`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Create Date:    12/15/2024 
// Design Name: 
// Module Name: mod_m_counter 
// Project Name: UART IP Core
// Description: UART Baud Rate Generator
//////////////////////////////////////////////////////////////////////////////////

module mod_m_counter (clk, reset, max_tick, q);

	parameter N = 8, 
		  M = 163;	// baud rate divisor
				// DVSR = 50MHz/(16*baud_rate)
			  
	input clk, reset;
	output [N-1:0] q;
	output max_tick;
	
	reg [N-1:0] q;
	
	always @(posedge clk)
		begin
			if(!reset)
				q <= {N{1'b0}};
			else
				q <= q + 1;
		end
	
	assign max_tick = (q == M)? 1'b1 : 1'b0; 
	
endmodule