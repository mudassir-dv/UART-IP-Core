`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Create Date:  12/16/2024 
// Design Name: UART Receiver Subsystem
// Module Name:  uart_rcvr 
// Project Name: UART IP Core
// Description: Transmitter subsystem with transmitter fsm and fifo buffer.
//	
//////////////////////////////////////////////////////////////////////////////////

module uart_txmt(clk, reset, s_tick, w_data, wr_uart, tx, tx_full);
	parameter W = 8;
	
	input clk, reset;
	input s_tick, wr_uart;
	input [W-1:0] w_data;
	output tx, tx_full;
	
	wire [W-1:0]tx_din;
	wire tx_done_tick, tx_empty;
	wire tx_fifo_not_empty; /* synthesis syn_keep=1 */
	
	fifo_buf FIFO_TX ( .clk(clk), 
						.reset(reset), 
						.wr_en(wr_uart), 
						.rd_en(tx_done_tick), 
						.w_data(w_data), 
						.r_data(tx_din), 
						.full(tx_full), 
						.empty(),
						.not_empty(tx_fifo_not_empty)
					);
					
	uart_tx UART_TX ( 	.clk(clk), 
						.reset(reset), 
						.tx_start(tx_fifo_not_empty), 
						.s_tick(s_tick), 
						.din(tx_din), 
						.tx_done_tick(tx_done_tick), 
						.tx(tx)
					);
					
endmodule
