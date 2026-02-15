`timescale 1ns / 1ps
//이제 fpga보드의 자원을 사용해서 ALU를 구현해봅시다!
module top_module(
    input clk,
    input [3:0] sw,      // sw[2:0]: Opcode, sw[3]: Reset
    input [3:0] btn,     // A++, A--, B++, B--
    output [7:0] seg,    // 7-segment Segments
    output [3:0] an,     // 7-segment Anodes
    output [3:0] led     // Opcode 확인용 LED (선택사항)
    );

    // 1. 내부 신호 선언
    reg [7:0] A = 0;
    reg [7:0] B = 0;
    wire [15:0] alu_result;
    wire zero_flag;

    // 2. 버튼 디바운싱 (간단하게 클럭 분주로 처리하거나 엣지 검출 사용)
    // 여기서는 간단히 rising edge 검출을 위한 로직을 짭니다.
    reg [3:0] btn_prev;
    always @(posedge clk) begin
        btn_prev <= btn; //이건 한 클럭 후 반영 되는 겁니다. 보드의 주파수가 100MHz니까 10ns가 한 클럭이겠죠?
    end
    
    // 버튼이 눌린 순간(0->1) 감지
    wire btn0_pressed = (btn[0] && !btn_prev[0]);
    wire btn1_pressed = (btn[1] && !btn_prev[1]);
    wire btn2_pressed = (btn[2] && !btn_prev[2]);
    wire btn3_pressed = (btn[3] && !btn_prev[3]);

    // 3. 입력 로직 (증감기)
    always @(posedge clk) begin
        if (sw[3]) begin // 스위치 3번이 켜지면 리셋
            A <= 0;
            B <= 0;
        end else begin
            if (btn0_pressed) A <= A + 1;
            if (btn1_pressed) A <= A - 1;
            if (btn2_pressed) B <= B + 1;
            if (btn3_pressed) B <= B - 1;
        end //각각의 버튼을 누르면 A 혹은 B의 값이 증감하는 로직!
    end

    // 4. ALU 연결
    // Opcode는 스위치 [2:0]을 그대로 사용
    alu_8bit my_alu (
        .A(A),
        .B(B),
        .opcode(sw[2:0]), // 스위치를 Opcode로 직결
        .out(alu_result),
        .zero_flag(zero_flag)
    );

    // 5. 7세그먼트 드라이버 연결 (RDX:RAX 출력)
    sseg_driver my_display (
        .clk(clk),
        .rst(sw[3]),      // 리셋은 sw[3] 공유
        .data_in(alu_result),
        .seg(seg),
        .an(an)
    );

    // LED에 현재 Opcode 상태 표시 (디버깅용)
    assign led[2:0] = sw[2:0]; 
    assign led[3] = zero_flag; // 마지막 LED는 제로 플래그

endmodule //전에 짜준 2비트 ALU 코드보다 훨씬 복잡해지네요 ㅜㅜ
