`timescale 1ns / 1ps
//이 코드는 능력이 안되서 AI한테 맡겼습니다...ㅜㅅㅜ 곱셈의 결과값이 16비트라서 이걸 효율적인 표기를 하기위해 4-digit 7-segment를 사용했는데, 이걸 사용하기 위한 드라이버입니다
//16 bit to 4-digit hexdecimal, 3641BS 소자를 사용했고, 이는 다이나믹 구동 방식을 사용하는 소자입니다
module sseg_driver(
    input clk,              // FPGA 100MHz Clock
    input rst,              // Reset Button
    input [15:0] data_in,   // 표시할 16비트 데이터 (Hex 4자리)
    output reg [7:0] seg,   // 세그먼트 제어 (DP, G, F, E, D, C, B, A) - Active Low
    output reg [3:0] an     // 자릿수 선택 (Anode) - Active High (3641BS 기준)
    );

    // 1. 클럭 분주 (속도 조절용)
    // 100MHz를 사람이 보기 좋은 속도로 낮춥니다.
    // 20비트 카운터 사용: 상위 2비트([19:18])를 자릿수 선택에 사용
    reg [19:0] refresh_counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end //20비트? 그러면... 주기가 약 10^6*10ns 정리하면 대충 주기가 10ms가 됨 그러면 주파수는 약 100Hz

    // 2. 자릿수 선택 신호 (active_digit) 생성
    wire [1:0] LED_activating_counter;
    assign LED_activating_counter = refresh_counter[19:18]; //20번째 비트 채워지려면 1ms, 19번째 비트 채워지려면 0.1ms

    // 3. 자릿수별 데이터(4비트) 추출 및 Anode 제어
    // 3641BS는 Common Anode이므로 자릿수 선택 핀(an)에 1을 줘야 켜집니다.
    reg [3:0] hex_digit;
    
    always @(*) begin
        case(LED_activating_counter)
            2'b00: begin
                an = 4'b0001; // 맨 오른쪽 (1의 자리)
                hex_digit = data_in[3:0]; // [3:0] 비트 표시 (16비트 데이터 중 맨 뒤의 4자리!)
            end
            2'b01: begin
                an = 4'b0010; // 십의 자리
                hex_digit = data_in[7:4]; // [7:4] 비트 표시
            end
            2'b10: begin
                an = 4'b0100; // 백의 자리
                hex_digit = data_in[11:8]; // [11:8] 비트 표시
            end
            2'b11: begin
                an = 4'b1000; // 맨 왼쪽 (천의 자리)
                hex_digit = data_in[15:12]; // [15:12] 비트 표시
            end
            default: begin
                an = 4'b0000;
                hex_digit = 4'b0000;
            end
        endcase //...그러면 주기는 똑같이 10ms, 한자리가 켜져있는 시간은? 10/4 = 약 2.5ms!
    end //이 조합회로는 지금 16비트를 4비트씩 잘라서 16진수로 바꿔서 표현하려고 하는 것이다 (우리가 binary를 hexadecimal로 변형하는 방식과 같음)

    // 4. 숫자 모양 만들기 (Decoder) - Active Low
    // 3641BS는 Cathode에 0을 줘야 불이 켜집니다.
    // 순서: {DP, G, F, E, D, C, B, A}
    always @(*) begin
        case(hex_digit)
            4'h0: seg = 8'b1100_0000; // 0
            4'h1: seg = 8'b1111_1001; // 1
            4'h2: seg = 8'b1010_0100; // 2
            4'h3: seg = 8'b1011_0000; // 3
            4'h4: seg = 8'b1001_1001; // 4
            4'h5: seg = 8'b1001_0010; // 5
            4'h6: seg = 8'b1000_0010; // 6
            4'h7: seg = 8'b1111_1000; // 7
            4'h8: seg = 8'b1000_0000; // 8
            4'h9: seg = 8'b1001_0000; // 9
            4'hA: seg = 8'b1000_1000; // A
            4'hB: seg = 8'b1000_0011; // b
            4'hC: seg = 8'b1100_0110; // C
            4'hD: seg = 8'b1010_0001; // d
            4'hE: seg = 8'b1000_0110; // E
            4'hF: seg = 8'b1000_1110; // F
            default: seg = 8'b1111_1111; // 끄기
        endcase
    end //binary 자료형을 바로 hexadecimal 자료형으로 바꿔서 그걸 그냥 7세그먼트에 맞게 대응 시켰을 뿐이다

endmodule
