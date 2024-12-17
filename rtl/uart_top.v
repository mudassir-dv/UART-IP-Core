`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Create Date:    00:24:31 12/17/2024 
// Design Name: UART Top 
// Module Name:    uart_top 
// Project Name: UART IP Core
// Description: UART Top Module -Default setting: 19,200 baud, 8 data bits,
//		1 stop bit, 8x8 FIFO.
//////////////////////////////////////////////////////////////////////////////////

module uart_top(clk, reset, rd_uart, wr_uart, rx, tx, w_data, r_data, tx_fifo_full, rx_fifo_empty, rx_fifo_full);
	parameter W = 8;
	
	input clk, reset;
	input rd_uart, wr_uart, rx;
	input [W-1:0] w_data;
	output [W-1:0] r_data;
	output tx_fifo_full, rx_fifo_empty, rx_fifo_full, tx;
	
	// Signal Declaration (for connections)
	wire tick;
	
	mod_m_counter BAUD_GEN	(	.clk(clk), 
								.reset(reset), 
								.max_tick(tick), 
								.q()
							);
	
	uart_rcvr UART_RCVR	(	.clk(clk), 
							.reset(reset), 
							.s_tick(tick), 
							.rx(rx), 
							.rd_uart(rd_uart), 
							.r_data(r_data), 
							.rx_empty(rx_fifo_empty), 
							.rx_full(rx_fifo_full)
						);
						
	uart_txmt UART_TXMT	(	.clk(clk), 
							.reset(reset), 
							.s_tick(tick), 
							.w_data(w_data), 
							.wr_uart(wr_uart), 
							.tx(tx), 
							.tx_full(tx_fifo_full)
						);
	
endmodule
