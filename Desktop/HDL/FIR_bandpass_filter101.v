module fir_filter #(
    parameter WIDTH = 16,           // 資料寬度，與係數位元寬度一致
    parameter TAP_NUM = 101         // tap 數 = 係數數 = 101
) (
    input wire clk,
    input wire rst_n,
    input wire signed [WIDTH-1:0] din,
    output reg signed [2*WIDTH+6:0] dout     // 輸出位寬抓大些避免溢位
);
    // tap 係數陣列
    reg signed [WIDTH-1:0] coef_array [0:TAP_NUM-1];
    // 資料延遲線
    reg signed [WIDTH-1:0] data_array [0:TAP_NUM-1];
    integer i;

    // --- 係數初始化（自動 include 你產生的 .vh 檔）
    initial begin
        `include "fir_coef_hex.vh"
    end

    // --- shift register：資料進延遲線
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<TAP_NUM; i=i+1) data_array[i] <= 0;
        end else begin
            data_array[0] <= din;
            for (i=1; i<TAP_NUM; i=i+1)
                data_array[i] <= data_array[i-1];
        end
    end

    // --- 串行乘加：每時鐘重新計算組合加權和
    reg signed [2*WIDTH+6:0] acc;
    always @(*) begin
        acc = 0;
        for (i=0; i<TAP_NUM; i=i+1)
            acc = acc + data_array[i] * coef_array[i];
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 0;
        else
            dout <= acc;
    end
endmodule
