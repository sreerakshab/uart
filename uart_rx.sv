`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 19:33:49
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input logic clk,
    input logic rst,
    input logic enb_16x,  
    input logic rx,       
    output logic [7:0] data_out, 
    output logic rx_done  
    );

typedef enum logic [1:0] {
    idle_state,
    start_state,
    data_state,
    stop_state
} state_t;

state_t state;

logic [2:0] index;       
logic [3:0] tick_count;  
logic [7:0] shift_reg;   

always_ff @(posedge clk) begin
    if (rst) begin
        state <= idle_state;
        index <= 0;
        tick_count <= 0;
        shift_reg <= 0;
        data_out <= 0;
        rx_done <= 0;
    end else begin
        rx_done <= 0;

        case(state)
            idle_state: begin
                if (rx == 1'b0) begin
                    state <= start_state;
                    tick_count <= 0;
                    index <= 0;
                end
            end

            start_state: begin
                if (enb_16x) begin
                    if (tick_count == 7) begin
                        if (rx == 1'b0) begin 
                            state <= data_state;
                            tick_count <= 0;
                        end else begin
                            state <= idle_state; 
                        end
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            end

            data_state: begin
                if (enb_16x) begin
                    if (tick_count == 15) begin
                        shift_reg[index] <= rx; 
                        tick_count <= 0;
                        
                        if (index == 7)
                            state <= stop_state;
                        else
                            index <= index + 1;
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            end

            stop_state: begin
                if (enb_16x) begin
                    if (tick_count == 15) begin
                        data_out <= shift_reg; 
                        rx_done <= 1'b1;       
                        state <= idle_state;   
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            end

            default: begin
                state <= idle_state;
            end
        endcase
    end
end

endmodule
