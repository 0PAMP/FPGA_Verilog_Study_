`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/10 21:31:49
// Design Name: 
// Module Name: top_tb
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


module top_tb(); // 테스트 벤치는 입력/출력 핀이 없습니다! (괄호 비어있음)

    // 1. DUT로 들어가는 입력 -> reg (내가 조작해야 함)
    reg [1:0] a;
    reg [1:0] b;
    reg [1:0] btn;

    // 2. DUT에서 나오는 출력 -> wire (결과를 지켜봐야 함)
    wire [3:0] led;

    // 3. 모듈 인스턴스화 (전선 연결)
    top uut (
        .sw({b, a}), // 스위치 4개에 a, b 연결
        .btn(btn),
        .led(led)
    );

    // 4. 조작 시작 (Stimulus)
    integer i; // 반복문을 위한 변수 (a용)
    integer j; // 반복문을 위한 변수 (b용)
    integer k; // 반복문을 위한 변수 (btn용)

    initial begin
        // 시뮬레이션 콘솔에 결과가 텍스트로 찍히게 설정 (모니터링)
        $monitor("시간=%0t | 버튼=%b | A=%d B=%d | 결과 LED=%b (%d)", 
                 $time, btn, a, b, led, led);
                 //여기서 잠깐! %b는 2진수, $t는 시간을 뜻합니다. %0t는 시간 앞에 나오는 빈칸을 없애는것이고...

        // 3중 반복문: 모든 경우의 수 (btn -> a -> b 순서로 변경)
        for (k = 0; k < 4; k = k + 1) begin      // 버튼 0~3 반복
            btn = k;
            for (i = 0; i < 4; i = i + 1) begin  // A 0~3 반복
                a = i;
                for (j = 0; j < 4; j = j + 1) begin // B 0~3 반복
                    b = j;
                    #10; // 10ns 대기 (결과 확인)
                end
            end
        end
        
        $finish; // 테스트 끝!
    end

endmodule