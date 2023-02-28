`timescale 1ns / 1ps

// DataMemory, 4 Bytes * 1024
// 上升沿进行写操作

module DataMemory(
    input reset, 
    input clock, 
    input [31:0] address, 
    input writeEnabled, 
    input readEnabled,
    input [31:0] writeInput,
    output [31:0] readResult
    );

    reg [31:0] data [0:2047];
    integer i;

    always @(posedge clock)
    begin
        if(reset)
        begin
            for(i = 0; i < 2048; i = i + 1)
                data[i] <= 32'b0;
        end
        else if(writeEnabled)
        begin
            data[address[31:2]] <= writeInput;
        end
    end

    assign readResult = readEnabled ? data[address[31:2]] : 32'b0;

endmodule