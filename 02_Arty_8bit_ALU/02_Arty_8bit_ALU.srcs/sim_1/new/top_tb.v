`timescale 1ns / 1ps

module top_tb;

    // 1. Inputs (Top Module로 들어가는 신호)
    reg clk;
    reg [3:0] sw;  // Opcode 제어용
    reg [3:0] btn; // 리셋 및 입력 제어용 (여기선 리셋만 씀)

    // 2. Outputs (Top Module에서 나오는 신호)
    wire [7:0] seg;
    wire [3:0] an;
    wire [3:0] led;

    // 3. Top Module 인스턴스화 (UUT: Unit Under Test)
    top_module uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .seg(seg),
        .an(an),
        .led(led)
    );

    // 4. 클럭 생성 (100MHz = 10ns 주기 -> 5ns마다 토글)
    always #5 clk = ~clk;

    // 5. 반복문 변수 선언
    integer op_idx; // Opcode 루프용
    integer i, j;   // A, B 루프용

    // 6. 테스트 시나리오 시작!
    initial begin
        // 초기화
        clk = 0;
        sw = 0;
        btn = 0;
        
        // 리셋 한 번 걸어주기 (sw[3]이 리셋이라고 가정)
        $display("=== [Start] Simulation Reset ===");
        sw[3] = 1; 
        #100;
        sw[3] = 0;
        #100;
        
        // Loop 1: 모든 연산(Opcode 0~7) 테스트
        for (op_idx = 0; op_idx < 8; op_idx = op_idx + 1) begin
            
            sw[2:0] = op_idx; // Opcode 변경
            $display("---------------------------------------------------");
            case(op_idx)
                0: $display("Testing Opcode %d: ADD (+)", op_idx);
                1: $display("Testing Opcode %d: SUB (-)", op_idx);
                2: $display("Testing Opcode %d: MUL (*)", op_idx);
                3: $display("Testing Opcode %d: AND (&)", op_idx);
                default: $display("Testing Opcode %d: Logic/Shift", op_idx);
            endcase
            $display("---------------------------------------------------");

            // Loop 2 & 3: A와 B 값 순회 (0 ~ 255)
            // *주의* 256*256 다 돌리면 로그가 너무 기니까, 
            // 0, 1, 2... 하고 띄엄띄엄(step 64) 돌려서 주요 값만 체크하겠습니다.
            
            for (i = 0; i < 256; i = i + 64) begin // 0, 64, 128, 192...
                for (j = 0; j < 256; j = j + 64) begin // 0, 64, 128, 192...
                    
                    // [핵심 기술] Top Module 내부 레지스터 강제 주입 (Hacking)
                    // 버튼 안 누르고 내부 변수 A, B를 직접 바꿉니다.
                    uut.A = i; 
                    uut.B = j;
                    
                    #20; // 계산될 시간 조금 줌

                    // 결과 출력 (곱셈일 때만 좀 더 자세히 볼까요?)
                    if (op_idx == 2) begin // MUL
                         $display("Time=%t | A=%d, B=%d | Result(Hex)=%h | Result(Dec)=%d", 
                                  $time, uut.A, uut.B, uut.alu_result, uut.alu_result);
                    end else if (op_idx == 0) begin // ADD
                         $display("Time=%t | A=%d, B=%d | Result(Hex)=%h | Carry?=%b", 
                                  $time, uut.A, uut.B, uut.alu_result, uut.alu_result[8]);
                    end
                end
            end
        end


        $display("---------------------------------------------------");
        $display("Special Test: MAX Value Multiplication (0xFF * 0xFF)");
        sw[2:0] = 2; // MUL
        uut.A = 255;
        uut.B = 255;
        #50;
        $display("A=255 * B=255 = %d (Expected: 65025, Hex: FE01)", uut.alu_result);
        
        if (uut.alu_result == 65025) 
            $display(">> SUCCESS! Perfect AMD64 Style Result.");
        else 
            $display(">> FAIL! Something is wrong.");

        $display("=== [End] Simulation Finished ===");
        $finish;
    end

endmodule
