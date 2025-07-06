function msg_serial = Window_Add(msg_In, symbol_num, FFT_num, CP_num,win_len)
% 工程友好型 16 点窗函数（升窗）
ramp_up = [0.0, ...
           0.03125, 0.09375, ...
           0.1875, 0.3125, 0.4375, ...
           0.5625, 0.6875, 0.78125, ...
           0.875, 0.921875, ...
           0.9609375, 0.98046875, ...
           0.990234375, 0.99609375, 1.0];
ramp_down = fliplr(ramp_up);


% ==== 拼接：采用 overlap-add ===
symbol_out_len = FFT_num + CP_num + win_len;
total_len = symbol_out_len + (symbol_num - 1)*(FFT_num + CP_num);
msg_serial = zeros(1, total_len);

for sym = 1:symbol_num
    x_cp = msg_In(sym, :);            % [CP + IFFT] = [32 + 256] = 288
    x = x_cp(CP_num+1:end);           % 提取 IFFT 段
    x_extend = [x_cp, x(1:win_len)];  % 拼接尾部窗段，长度 288 + 16 = 304

    % 构造窗函数
    win_full = [ramp_up, ...
                ones(1, length(x_cp) - win_len), ...
                ramp_down];           % 长度 288
    % 加窗
    x_win = x_extend .* win_full;

    % 叠加拼接
    start_idx = (sym - 1)*(FFT_num + CP_num) + 1;
    end_idx   = start_idx + symbol_out_len - 1;
    msg_serial(start_idx:end_idx) = msg_serial(start_idx:end_idx) + x_win;
end
end
