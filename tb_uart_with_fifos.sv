`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2026 12:59:08
// Design Name: 
// Module Name: tb_uart_with_fifos
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


module tb_uart_with_fifos;

    logic clk;
    logic rst;
    logic [7:0] user_tx_data;
    logic user_tx_wr_en;
    logic tx_fifo_full;
    logic [7:0] user_rx_data;
    logic user_rx_rd_en;
    logic rx_fifo_empty;
    logic serial_wire;

    uart_with_fifos uut (
        .clk(clk),
        .rst(rst),
        .user_tx_data(user_tx_data),
        .user_tx_wr_en(user_tx_wr_en),
        .tx_fifo_full(tx_fifo_full),
        .user_rx_data(user_rx_data),
        .user_rx_rd_en(user_rx_rd_en),
        .rx_fifo_empty(rx_fifo_empty),
        .uart_rxd(serial_wire),   
        .uart_txd(serial_wire)    
    );

    initial begin
        clk = 1;
        forever #5 clk = ~clk; 
    end

    integer i;

    initial begin
        rst = 1;
        user_tx_data = 0;
        user_tx_wr_en = 0;
        user_rx_rd_en = 0;

        #100;
        rst = 0;
        
        // Wait until 1400ns. Vivado pauses at 1000ns, so you type "run -all"
        #1300; 
        @(posedge clk); 

        for (i = 1; i <= 15; i = i + 1) begin
            
            @(posedge clk); 
            
            if (i <= 8) user_tx_data = i;
            else        user_tx_data = 8; 

            $display("[%0d ns] TX_FIFO WRITE : %0d", $time/1000, user_tx_data);

            #1; 
            user_tx_wr_en = 1;
            
            @(posedge clk); 
            #1; 
            user_tx_wr_en = 0;

            repeat(2) @(posedge clk); 
        end

        @(posedge clk);
        user_tx_data = 0;
        $display("[%0d ns] TX_FIFO WRITE : %0d", $time/1000, user_tx_data);
        
        #1; 
        user_tx_wr_en = 1;
        @(posedge clk);
        #1; 
        user_tx_wr_en = 0;

        #25000000; 

        while (rx_fifo_empty == 1'b0) begin
            
            @(posedge clk);
            #1;
            user_rx_rd_en = 1;
            
            @(posedge clk);
            #1;
            user_rx_rd_en = 0;
            
            repeat(2) @(posedge clk); 

            #1;
            $display("[%0d ns] RX_FIFO READ  : %0d", $time/1000, user_rx_data);

            #40;
        end

        #1000;
        $display("\n[%0d ns] Simulation Complete!", $time/1000);
        $finish;
    end

endmodule