clc; clear; close all;

% 原始参数设置
fs = 1000;                    % 原始采样率 (Hz)
t = 0:1/fs:1-1/fs;           % 时间向量 (1秒时长)
f0 = 100;                    % 正弦波频率 (Hz)
x = sin(2*pi*f0*t);          % 原始正弦信号

% 升采样操作（插零 + FIR插值滤波器）
L = 2;                       % 升采样因子
x_upsampled = upsample(x, L);     % 仅插零操作
x_up_filtered = interp(x, L);     % 插值滤波（插零 + 低通滤波器）

% 降采样操作（FIR抗混叠滤波器 + 抽取）
M = 2;                       % 降采样因子
x_down_filtered = decimate(x, M); % 抗混叠滤波 + 抽取（组合操作）

% 绘制对比分析图
figure('Position', [100, 100, 1000, 800]);

% 原始信号频谱
subplot(4,1,1);
freq_axis_orig = linspace(-fs/2, fs/2, length(x));
spectrum_orig = abs(fftshift(fft(x)));
plot(freq_axis_orig, spectrum_orig, 'LineWidth', 1.5);
title('原始信号频谱 (fs = 1000 Hz)');
ylabel('|X(f)|');
xlim([-500, 500]);
grid on;

% 升采样（仅插零）频谱
subplot(4,1,2);
freq_axis_up_zero = linspace(-(fs*L)/2, (fs*L)/2, length(x_upsampled));
spectrum_up_zero = abs(fftshift(fft(x_upsampled)));
plot(freq_axis_up_zero, spectrum_up_zero, 'LineWidth', 1.5);
title('升采样×2（仅插零）频谱');
ylabel('|X_{zero}(f)|');
xlim([-1000, 1000]);
grid on;

% 升采样（插值滤波）频谱
subplot(4,1,3);
freq_axis_up_filt = linspace(-(fs*L)/2, (fs*L)/2, length(x_up_filtered));
spectrum_up_filt = abs(fftshift(fft(x_up_filtered)));
plot(freq_axis_up_filt, spectrum_up_filt, 'LineWidth', 1.5);
title('升采样×2（插值滤波）频谱');
ylabel('|X_{up}(f)|');
xlim([-1000, 1000]);
grid on;

% 降采样频谱
subplot(4,1,4);
freq_axis_down = linspace(-(fs/M)/2, (fs/M)/2, length(x_down_filtered));
spectrum_down = abs(fftshift(fft(x_down_filtered)));
plot(freq_axis_down, spectrum_down, 'LineWidth', 1.5);
title('降采样÷2后频谱');
ylabel('|X_{down}(f)|');
xlabel('频率 (Hz)');
xlim([-250, 250]);
grid on;

% 添加整体标题
sgtitle('采样率变换对信号频谱的影响分析', 'FontSize', 14, 'FontWeight', 'bold');

% 输出关键信息
fprintf('\n================ 采样率变换分析报告 ================\n');
fprintf('原始信号参数:\n');
fprintf('  - 采样频率: %d Hz\n', fs);
fprintf('  - 信号频率: %d Hz\n', f0);
fprintf('  - 信号长度: %d 样本点\n', length(x));
fprintf('  - 奈奎斯特频率: %d Hz\n', fs/2);

fprintf('\n升采样分析:\n');
fprintf('  - 升采样因子: %d\n', L);
fprintf('  - 新采样频率: %d Hz\n', fs*L);
fprintf('  - 新信号长度: %d 样本点\n', length(x_up_filtered));
fprintf('  - 新奈奎斯特频率: %d Hz\n', (fs*L)/2);

fprintf('\n降采样分析:\n');
fprintf('  - 降采样因子: %d\n', M);
fprintf('  - 新采样频率: %d Hz\n', fs/M);
fprintf('  - 新信号长度: %d 样本点\n', length(x_down_filtered));
fprintf('  - 新奈奎斯特频率: %d Hz\n', (fs/M)/2);

fprintf('\n频谱特征观察:\n');
fprintf('  - 原始信号在 ±%d Hz 处有主要频谱分量\n', f0);
fprintf('  - 升采样后频谱在 ±%d Hz 和 ±%d Hz 处重复\n', f0, fs-f0);
fprintf('  - 插值滤波有效抑制了高频重复分量\n');
fprintf('  - 降采样后频谱保持在 ±%d Hz 处\n', f0);
fprintf('===================================================\n');