`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2026 14:30:09
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input logic clk,wr_enb,rst,enb,
    input logic [7:0] data_in,
    output logic tx, busy
    );
    
typedef enum logic [1:0] {
        idle_state,
        start_state,
        data_state,
        stop_state
    } state_t;
    
    state_t state;

logic [7:0] data;
logic [2:0] index;

always_ff@(posedge clk) begin
    if (rst) begin
        tx <= 1'b1;
        state <= idle_state;
        index <= 0;
        data  <= 0;
    end
        
    else
    begin
        case(state)
            idle_state:
                begin
                tx <= 1'b1;
                    if(wr_enb)
                        begin
                            state <= start_state;
                            data <= data_in;
                            index <= 0;
                        end
                end
            
            start_state:
                begin
                tx <= 1'b0;
                    if (enb)
                        begin
                            state <= data_state;
                        end
                end
            
            data_state:
                begin
                    tx <= data[index];   
                
                    if (enb)
                    begin
                        if (index == 7)
                            state <= stop_state;
                        else
                            index <= index + 1;
                    end
                end
            
            stop_state:
                begin
                tx <= 1'b1;
                    if (enb)
                        begin
                            state <= idle_state;
                        end
                end
            
            default: begin
                    tx <= 1'b1;
                    state <= idle_state;
            end
            endcase
        end
    end
        
assign busy = (state != idle_state);

endmodule
