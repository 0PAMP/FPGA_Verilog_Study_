`timescale 1ns / 1ps

module alu_8bit(
    input [7:0] A, 
    input [7:0] B,
    input [2:0] opcode,     // 기능 선택
    output reg [15:0] out, // 결과 (곱셈을 진행하면 16비트)
    output zero_flag
);

// 연산 코드 정의 (가독성을 위해 파라미터 사용...할 수가 있구나)
    parameter OP_ADD = 3'b000;
    parameter OP_SUB = 3'b001;
    parameter OP_MUL = 3'b010; // AMD64 스타일 곱셈 (반반나눠서 상위비트:하위비트 구조)
    parameter OP_AND = 3'b011;
    parameter OP_OR  = 3'b100;
    parameter OP_XOR = 3'b101;
    parameter OP_SLL = 3'b110; // Shift Left
    parameter OP_SRL = 3'b111; // Shift Right

    always @(*) begin
        case(opcode)
            OP_ADD: out = A + B;             // 덧셈 (결과는 하위 8비트에, 캐리는 9번째 비트)
            OP_SUB: out = A - B;             // 뺄셈
            OP_MUL: out = A * B;             // 곱셈 (8bit * 8bit = 16bit), fpga 보드상에서는 16비트 값이 그냥 나옵니다
            OP_AND: out = {8'b0, (A & B)};   // 논리 연산은 상위 8비트 0으로 채움 (논리게이트 내에서 연산을 해야하니까 이렇게 짜줬네! 이렇게 짜지 않으면 carry가 생겨버린다!)
            OP_OR : out = {8'b0, (A | B)};
            OP_XOR: out = {8'b0, (A ^ B)};
            OP_SLL: out = {8'b0, (A << 1)};  // 1비트 왼쪽 시프트 (원한다면 B만큼 시프트: A << B)
            OP_SRL: out = {8'b0, (A >> 1)};  // 1비트 오른쪽 시프트
            default: out = 16'b0;
        endcase
    end

    // 제로 플래그: 결과의 하위 8비트(RAX)가 0일 때 켜짐
    assign zero_flag = (out[7:0] == 8'b0);

endmodule