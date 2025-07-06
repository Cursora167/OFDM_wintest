%% 加窗参数
%% 构建信号序列
% 按照指定顺序组合信号: [msg_blank, short_pream, long_pream, msg_ifft(1,:), ..., msg_ifft(8,:), msg_blank]
signal_parts = {msg_blank, short_pream, long_pream};
for k = 1:size(msg_ifft, 1)
    signal_parts{end+1} = msg_ifft(k, :);
end
signal_parts{end+1} = msg_blank;

% 拼接完整信号
full_signal = [];
segment_boundaries = [1];  % 记录各段边界位置
for k = 1:length(signal_parts)
    full_signal = [full_signal, signal_parts{k}];
    segment_boundaries(end+1) = length(full_signal) + 1;
end

%% 升余弦加窗处理
windowed_signal = full_signal;

% 生成升余弦窗函数
n = 0:(2*WINDOW_LENGTH-1);
rc_window = 0.5 * (1 - cos(pi * n / WINDOW_LENGTH));

% 在各段连接处应用加窗
for k = 2:(length(segment_boundaries)-1)
    boundary_pos = segment_boundaries(k);
    
    % 前段末尾加渐降窗
    start_fade = max(1, boundary_pos - WINDOW_LENGTH);
    end_fade = boundary_pos - 1;
    fade_length = end_fade - start_fade + 1;
    if fade_length > 0
        window_part = rc_window((2*WINDOW_LENGTH-fade_length+1):2*WINDOW_LENGTH);
        windowed_signal(start_fade:end_fade) = windowed_signal(start_fade:end_fade) .* window_part;
    end
    
    % 后段开头加渐升窗
    start_rise = boundary_pos;
    end_rise = min(length(windowed_signal), boundary_pos + WINDOW_LENGTH - 1);
    rise_length = end_rise - start_rise + 1;
    if rise_length > 0
        window_part = rc_window(1:rise_length);
        windowed_signal(start_rise:end_rise) = windowed_signal(start_rise:end_rise) .* window_part;
    end
end

%% 结果可视化
figure;

subplot(2,1,1);
plot(real(full_signal), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hold on;
plot(real(windowed_signal), 'r-', 'LineWidth', 1.2);
title('OFDM信号加窗处理结果');
xlabel('样点索引');
ylabel('信号幅度');
legend('原始信号', '加窗信号', 'Location', 'best');
grid on;

subplot(2,1,2);
[Pxx_orig, f] = pwelch(full_signal, [], [], [], 1, 'centered');
[Pxx_wind, ~] = pwelch(windowed_signal, [], [], [], 1, 'centered');
plot(f, 10*log10(Pxx_orig), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hold on;
plot(f, 10*log10(Pxx_wind), 'r-', 'LineWidth', 1.2);
title('功率谱密度比较');
xlabel('归一化频率');
ylabel('功率谱密度 (dB)');
legend('原始信号', '加窗信号', 'Location', 'best');
grid on;

fprintf('加窗处理完成，信号长度: %d 样点\n', length(windowed_signal));