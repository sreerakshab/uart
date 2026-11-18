`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2026 12:53:13
// Design Name: 
// Module Name: uart_with_fifos
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module uart_with_fifos (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] user_tx_data,
    input  logic       user_tx_wr_en,
    output logic       tx_fifo_full,
    output logic [7:0] user_rx_data,
    input  logic       user_rx_rd_en,
    output logic       rx_fifo_empty,
    input  logic uart_rxd,
    output logic uart_txd
);

    logic enb_16x, enb;
    logic [7:0] rx_byte, tx_byte_from_fifo;
    logic rx_done, tx_busy;
    logic tx_fifo_empty_internal, fifo_rd_en, uart_wr_enb;

    baud_gen #(
        .CLK_FREQ(100_000_000), 
        .BAUD_RATE(9600)
    ) my_baud_gen (
        .clk(clk), 
        .rst(rst),
        .enb_16x(enb_16x), 
        .enb(enb)
    );

    fifo_bram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(8) 
    ) tx_fifo (
        .clk(clk), 
        .rst(rst),
        .wr_en(user_tx_wr_en), 
        .rd_en(fifo_rd_en), 
        .din(user_tx_data), 
        .dout(tx_byte_from_fifo),
        .full(tx_fifo_full), 
        .empty(tx_fifo_empty_internal) 
    );

    uart_tx my_tx (
        .clk(clk), 
        .wr_enb(uart_wr_enb), 
        .rst(rst), 
        .enb(enb),
        .data_in(tx_byte_from_fifo),
        .tx(uart_txd), 
        .busy(tx_busy)
    );

    uart_rx my_rx (
        .clk(clk), 
        .rst(rst), 
        .enb_16x(enb_16x),
        .rx(uart_rxd),
        .data_out(rx_byte), 
        .rx_done(rx_done)
    );

    fifo_bram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(8) 
    ) rx_fifo (
        .clk(clk), 
        .rst(rst),
        .wr_en(rx_done),       
        .rd_en(user_rx_rd_en), 
        .din(rx_byte), 
        .dout(user_rx_data),
        .full(),               
        .empty(rx_fifo_empty) 
    );

    typedef enum logic [1:0] { IDLE, WAIT_FIFO, SEND } state_t;
    state_t state = IDLE;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            fifo_rd_en <= 0;
            uart_wr_enb <= 0;
        end else begin
            fifo_rd_en <= 0;
            uart_wr_enb <= 0;

            case (state)
                IDLE: begin
                    if (!tx_busy && !tx_fifo_empty_internal) begin
                        fifo_rd_en <= 1; 
                        state <= WAIT_FIFO;
                    end
                end
                
                WAIT_FIFO: begin
                    uart_wr_enb <= 1; 
                    state <= SEND;
                end
                
                SEND: begin
                    if (tx_busy) begin
                        state <= IDLE; 
                    end
                end
            endcase
        end
    end
endmodule
