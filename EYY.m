%% 加窗 - 改进版本
WINDOW_LENGTH = 16; % 窗长度

% 构建信号序列
signal_parts = {msg_blank, short_pream, long_pream};
for k = 1:size(msg_ifft, 1)
    signal_parts{end+1} = msg_ifft(k, :);
end
signal_parts{end+1} = msg_blank;

% 拼接完整信号
full_signal = [];
segment_boundaries = [1]; % 记录各段边界位置
for k = 1:length(signal_parts)
    full_signal = [full_signal, signal_parts{k}];
    segment_boundaries(end+1) = length(full_signal) + 1;
end

%% 方法1：修正的窗函数设计（确保互补性）
% 生成互补的升余弦窗函数
n = 0:(WINDOW_LENGTH-1);
% 确保窗函数满足 rise + fall = 1
rc_rise = 0.5 * (1 - cos(pi * n / (WINDOW_LENGTH-1)));  % 上升窗
rc_fall = 0.5 * (1 + cos(pi * n / (WINDOW_LENGTH-1)));  % 下降窗

% 验证窗函数的互补性
window_sum = rc_rise + rc_fall;
fprintf('窗函数互补性检查：最大偏差 = %.6f\n', max(abs(window_sum - 1)));

%% 方法2：改进的加窗和叠加处理
% 初始化
windowed_signal = full_signal;
End_signal = [];

% 处理第一段（不加窗）
End_signal = signal_parts{1};

% 处理中间各段
for k = 2:(length(signal_parts)-1)
    current_part = signal_parts{k};
    prev_part = signal_parts{k-1};
    
    % 提取重叠部分
    prev_tail = prev_part(end-WINDOW_LENGTH+1:end);
    curr_head = current_part(1:WINDOW_LENGTH);
    
    % 应用互补窗函数
    windowed_prev = prev_tail .* rc_fall;
    windowed_curr = curr_head .* rc_rise;
    
    % 叠加
    overlap_sum = windowed_prev + windowed_curr;
    
    % 构建输出信号
    if k == 2
        % 第二段特殊处理（跳过第一段的末尾）
        End_signal = [End_signal(1:end-WINDOW_LENGTH), overlap_sum, current_part(WINDOW_LENGTH+1:end)];
    else
        % 其他段
        End_signal = [End_signal, overlap_sum, current_part(WINDOW_LENGTH+1:end)];
    end
end

% 处理最后一段
last_part = signal_parts{end};
prev_part = signal_parts{end-1};

% 最后一个重叠
prev_tail = prev_part(end-WINDOW_LENGTH+1:end);
last_head = last_part(1:min(WINDOW_LENGTH, length(last_part)));

if length(last_head) == WINDOW_LENGTH
    windowed_prev = prev_tail .* rc_fall;
    windowed_last = last_head .* rc_rise;
    overlap_sum = windowed_prev + windowed_last;
    End_signal = [End_signal, overlap_sum, last_part(WINDOW_LENGTH+1:end)];
else
    % 如果最后一段太短，简单拼接
    End_signal = [End_signal, last_part];
end

%% 画图
figure('Position', [100, 100, 1200, 800]);

% 时域信号对比
subplot(3,1,1);
plot(real(full_signal), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hold on;
plot(real(End_signal), 'r-', 'LineWidth', 1.2);
title('OFDM信号Overlap-Add处理结果');
xlabel('样点索引');
ylabel('信号幅度');
legend('原始信号', 'Overlap-Add信号', 'Location', 'best');
grid on;

% 局部放大 - 显示一个连接点
subplot(3,1,2);
boundary_idx = segment_boundaries(3); % 第一个重要边界
plot_range = (boundary_idx-2*WINDOW_LENGTH):(boundary_idx+2*WINDOW_LENGTH-1);
plot(plot_range, real(full_signal(plot_range)), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hold on;
plot(plot_range, real(End_signal(plot_range)), 'r-', 'LineWidth', 1.2);
xline(boundary_idx-1, 'k--', 'LineWidth', 1);
title('连接点局部放大（验证连续性）');
xlabel('样点索引');
ylabel('信号幅度');
legend('原始信号', 'Overlap-Add信号', '边界位置', 'Location', 'best');
grid on;

% 功率谱密度比较
subplot(3,1,3);
[Pxx_orig, f] = pwelch(full_signal, [], [], [], 1, 'centered');
[Pxx_end, ~] = pwelch(End_signal, [], [], [], 1, 'centered');
plot(f, 10*log10(Pxx_orig), 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hold on;
plot(f, 10*log10(Pxx_end), 'r-', 'LineWidth', 1.2);
title('功率谱密度比较');
xlabel('归一化频率');
ylabel('功率谱密度 (dB)');
legend('原始信号', 'Overlap-Add信号', 'Location', 'best');
grid on;
ylim([-80, max(10*log10(Pxx_orig))+10]);

%% 性能评估
% 计算旁瓣抑制比
[~, main_lobe_idx] = max(Pxx_orig);
main_lobe_range = max(1, main_lobe_idx-10):min(length(Pxx_orig), main_lobe_idx+10);
side_lobe_range = setdiff(1:length(Pxx_orig), main_lobe_range);

SLSR_orig = 10*log10(max(Pxx_orig(main_lobe_range)) / max(Pxx_orig(side_lobe_range)));
SLSR_end = 10*log10(max(Pxx_end(main_lobe_range)) / max(Pxx_end(side_lobe_range)));

fprintf('\n性能评估结果：\n');
fprintf('原始信号旁瓣抑制比: %.2f dB\n', SLSR_orig);
fprintf('Overlap-Add信号旁瓣抑制比: %.2f dB\n', SLSR_end);
fprintf('改善量: %.2f dB\n', SLSR_end - SLSR_orig);