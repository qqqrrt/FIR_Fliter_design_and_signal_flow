% 參數設定
Fs = 48000;
N = 101;
Fpass1 = 6000;
Fpass2 = 12000;
Wn = [Fpass1 Fpass2]/(Fs/2);

% FIR 濾波器設計
h = fir1(N-1, Wn, 'bandpass', hamming(N));
fir_coef = round(h * (2^15));   % Q15 int16

% 波型測試信號：三頻疊加
%t = (0:Fs/10-1)/Fs;
%x = sin(2*pi*1000*t) + sin(2*pi*8000*t) + sin(2*pi*16000*t);

% 產生方波
x = square(2*pi*7000*t);

% 若要振幅 Q15（與你的Verilog相同，-32768~+32767）
x = int16(x * 32767);

% 畫圖顯示
plot(t, y); grid on; title('MATLAB 方波');
xlabel('Time (s)'); ylabel('Amplitude');

% 濾波效果驗證
y = filter(h, 1, x);
figure;
subplot(2,1,1); plot(t, x); grid on; title('原始三頻訊號');
subplot(2,1,2); plot(t, y); grid on; title('FIR濾波後訊號');



% 匯出10進制 .vh 檔案
fid = fopen('fir_coef_dec.vh', 'w');
for i = 1:length(fir_coef)
    fprintf(fid, 'coef_array[%d] = 16''sd%d;\n', i-1, fir_coef(i));
end
fclose(fid);

% 匯出16進制 .vh 檔案（兩補數格式，Verilog可用）
fir_coef_hex = dec2hex(typecast(int16(fir_coef), 'uint16'), 4);
fid = fopen('fir_coef_hex.vh', 'w');
for i = 1:length(fir_coef_hex)
    fprintf(fid, 'coef_array[%d] = 16''h%s;\n', i-1, fir_coef_hex(i,:));
end
fclose(fid);

disp('10進制 fir_coef_dec.vh、16進制 fir_coef_hex.vh 已完成，可直接include於Verilog module。');
