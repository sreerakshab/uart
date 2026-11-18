`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2026 11:56:50
// Design Name: 
// Module Name: baud_gen
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


module baud_gen #(
    parameter CLK_FREQ = 100_000_000, 
    parameter BAUD_RATE = 9600,
    parameter RX_MAX = (CLK_FREQ / (BAUD_RATE * 16)) - 1, 
    parameter TX_MAX = (CLK_FREQ / BAUD_RATE) - 1
)(
    input  logic clk,
    input  logic rst,
    output logic enb_16x, 
    output logic enb      
);

    integer rx_counter;
    integer tx_counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            rx_counter <= 0;
            tx_counter <= 0;
            enb_16x <= 0;
            enb <= 0;
        end else begin
            enb_16x <= 0;
            enb <= 0;
            if (rx_counter >= RX_MAX) begin
                rx_counter <= 0;
                enb_16x <= 1'b1; 
            end else begin
                rx_counter <= rx_counter + 1;
            end
            if (tx_counter >= TX_MAX) begin
                tx_counter <= 0;
                enb <= 1'b1;     
            end else begin
                tx_counter <= tx_counter + 1;
            end
        end
    end

endmodule
