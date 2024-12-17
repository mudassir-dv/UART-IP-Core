`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Create Date:    12/15/2024 
// Design Name: UART Receiver
// Module Name:    uart_rx 
// Project Name: UART IP Core
// Description: A shift register that receives data serially through rx line 
//			    at a specific baud rate.
//////////////////////////////////////////////////////////////////////////////////

module uart_rx(clk, reset, rx, s_tick, rx_done_tick, dout);
	parameter DBIT = 8,
			  SB_TICK = 16;
	
	input clk, reset;
	input rx, s_tick;
	output reg rx_done_tick;
	output [7:0] dout;
	
	//State Declarations
	parameter [1:0] IDLE  = 2'b00,
					START = 2'b01,
					DATA  = 2'b10,
					STOP  = 2'b11;	
		
	// Signal Declarations	
	reg [1:0] cur_state, next_state;
	reg [7:0] b_reg, b_next;
	reg [2:0] n_reg, n_next;
	reg [3:0] s_reg, s_next;
	
	//FSM cur_state logic
	always @(posedge clk, negedge reset)
		begin
			if(!reset)
				begin
					cur_state <= IDLE;
					b_reg	<= 0;
					n_reg	<= 0;
					s_reg 	<= 0;
				end
			else
				begin
					cur_state <= next_state;
					b_reg <= b_next;
					n_reg <= n_next;
					s_reg <= s_next;
				end
		end
		
	//FSM next_state logic
	always @(*)
		begin
			next_state = cur_state;
			rx_done_tick = 1'b0;
			s_next = s_reg;
			n_next = n_reg;
			b_next = b_reg;
			
			case(cur_state)
				IDLE	: begin 
							if(rx == 1'b0)
								begin
									next_state = START;
									s_next = 0;
								end
						  end
						  
				START	: begin
							if(s_tick) 
								if(s_reg == 7)
									begin
										next_state = DATA;
										s_next = 0;
										n_next = 0;
									end
								else
									s_next = s_reg + 1;
						 end
						 
				DATA	: begin
							if(s_tick)
								if(s_reg == 15)
									begin
										s_next = 0;
										b_next = {rx, b_reg[7:1]};
										if(n_reg == (DBIT-1))
											next_state = STOP;
										else
											n_next = n_reg + 1;
									end
								else
									s_next = s_reg + 1;
						 end
						 
				STOP	: begin
							if(s_tick)
								if(s_reg == (SB_TICK-1))
									begin
										next_state = IDLE;
										rx_done_tick = 1'b1;
									end
								else
									s_next = s_reg + 1;
						  end
			endcase
		end
	
	assign dout = b_reg;
	
endmodule