`timescale 1ns/1ps

module tb_fir_filter;
    parameter WIDTH   = 16;
    parameter TAP_NUM = 101;


    reg clk, rst_n;
    reg signed [WIDTH-1:0] din;
    wire signed [2*WIDTH+6:0] dout;

    // 例化 FIR 濾波器
    fir_filter #(.WIDTH(WIDTH), .TAP_NUM(TAP_NUM)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .dout(dout)
    );
    integer i;  // 變數在 module 最前
    // 產生 50MHz 時鐘
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 實現 reset
    initial begin
        rst_n = 0;
        din   = 0;
        #50;
        rst_n = 1;
    end

    // 資料激勵 (全部同步於 clk 並延後幾拍啟動)
    initial begin
        @(posedge rst_n);     // 等待 reset 結束
        repeat(3) @(posedge clk);

        // 步進輸入
        din = 1000; repeat(20) @(posedge clk);
        din = 2000; repeat(20) @(posedge clk);
        din = 0;    repeat(20) @(posedge clk);

        // 方波測試
        for (i=0; i<30; i=i+1) begin
            din = 4096; @(posedge clk);
            din = 0;    @(posedge clk);
        end

        // 三角波測試
        for (i=0; i<20; i=i+1) begin
            din = i * 100; @(posedge clk);
        end
        for (i=19; i>=0; i=i-1) begin
            din = i * 100; @(posedge clk);
        end

        // 結束
        #200;
        $finish;
    end

    // 監控波形
    initial begin
        $display("     t |    din  |     dout");
        $monitor("%6t | %6d | %8d", $time, din, dout);
    end
endmodule
