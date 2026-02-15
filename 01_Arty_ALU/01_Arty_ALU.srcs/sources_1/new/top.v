`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/10 21:31:30
// Design Name: 
// Module Name: top
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


module top(
    input [3:0] sw,      // A(sw[1:0]), B(sw[3:2])
    input [1:0] btn,     // 기능 선택 (00, 01, 10, 11)
    output reg [3:0] led // 결과 (넉넉하게 4비트)
);

    wire [1:0] A = sw[1:0];
    wire [1:0] B = sw[3:2];

    // always @(*) : 입력이 바뀌면 즉시 실행 (조합회로) / 클럭과는 무관하다는 뜻
    always @(*) begin
        case (btn)
            2'b00: led = A + B;      // 덧셈
            2'b01: led = A - B;      // 뺄셈
            2'b10: led = {2'b00, (A & B)}; // AND (비트수 맞춤)
            2'b11: led = {2'b00, (A | B)}; // OR (비트수 맞춤)
            default: led = 0;        // 혹시 모를 에러 방지
        endcase
    end

endmodule
