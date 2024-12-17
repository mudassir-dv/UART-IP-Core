`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:01:29 12/16/2024 
// Design Name: 	UART Transmitter
// Module Name:    uart_tx 
// Project Name: UART IP Core
// Description: A shift register that transmits data serially through tx line 
//				at a specific baud rate.
//////////////////////////////////////////////////////////////////////////////////

module uart_tx(clk, reset, tx_start, s_tick, din, tx_done_tick, tx);
	parameter DBIT = 8,			// Data bits
				 SB_TICK = 16;		// ticks for stop bits

	input clk, reset;
	input tx_start, s_tick;
	input [7:0] din;
	output tx;
	output reg tx_done_tick;
	
	//State Declarations
	parameter [1:0] IDLE  = 2'b00,
					START = 2'b01,
					DATA  = 2'b10,
					STOP  = 2'b11;
	
	//Signal Declaration
	reg [1:0] cur_state, next_state;
	reg [7:0] b_reg, b_next;
	reg [2:0] n_reg, n_next;
	reg [3:0] s_reg, s_next;
	reg tx_reg, tx_next;
	
	//FSM cur_state logic
	always @(posedge clk, negedge reset)
		begin
			if(!reset)
				begin
					cur_state <= IDLE;
					b_reg	<= 0;
					n_reg	<= 0;
					s_reg 	<= 0;
					tx_reg  <= 1'b1;
				end
			else
				begin
					cur_state <= next_state;
					b_reg <= b_next;
					n_reg <= n_next;
					s_reg <= s_next;
					tx_reg <= tx_next;
				end
		end
		
		
	//FSM next_state logic
	always @(*)
		begin
			next_state = cur_state;
			tx_done_tick = 1'b0;
			s_next = s_reg;
			n_next = n_reg;
			b_next = b_reg;
			tx_next = tx_reg;

			case(cur_state)
				IDLE	: begin 
							if(tx_start)
								begin
									next_state = START;
									s_next = 0;
									b_next = din;
								end
						  end
						  
				START	: begin
							tx_next = 1'b0; 
							if(s_tick)
								if(s_reg == 15)
									begin
										next_state = DATA;
										s_next = 0;
										n_next = 0;
									end
							else
								s_next = s_reg + 1;
						 end
						 
				DATA	: begin
							tx_next = b_reg[0];
							if(s_tick)
								if(s_reg == 15)
									begin
										s_next = 0;
										b_next = b_reg >> 1;
										if(n_reg == (DBIT-1))
											next_state = STOP;
										else
											n_next = n_reg + 1;
									end
								else
									s_next = s_reg + 1;
						 end
						 
				STOP	: begin
							tx_next = 1'b1; 
							if(s_tick)
								if(s_reg == (SB_TICK-1))
									begin
										next_state = IDLE;
										tx_done_tick = 1'b1;
									end
								else
									s_next = s_reg + 1;
						  end
			endcase
		end	
		
	//Output tx Logic
	assign tx = tx_reg;
	
endmodule
