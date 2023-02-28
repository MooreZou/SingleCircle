`timescale 1ns / 1ps

module ProgramCounter(
    input reset, 
    input clock, 
    input jumpEnabled, 
    input [31:0] jumpInput,
    output [31:0] pcValue
    );
    
    reg [31:0] pc;
    assign pcValue = pc;
    
    always @(posedge clock)
    begin
        if(reset)
        begin
            pc <= 32'h3000;
        end
        else if(jumpEnabled)
        begin
            pc <= jumpInput;
        end
        else
        begin
            pc <= pc + 32'h4;
        end
    end

endmodule