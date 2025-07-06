function [msg_Out,frame_lost,start_local] =...
    frame_detect(msg_In,pream_length,symbol_num,FFT_num,CP_num,data_Sub)
%帧检测与粗频偏估计
%% 参数设置
frame_detect_th = 0.5;                                                      %帧检测判决门限；
frame_detect_winth = 64;                                                    %帧检测窗口长度；
detect_count_phase = 100;                                                   %粗频偏使用位置；
detect_count_max = 160;                                                     %平台计数max值;
detect_worng_max = 210;                                                     %平台计数保护值；
correct_local = 68;                                                         %粗频偏纠正起始位置，根据vivado理想仿真得到；
data_length = pream_length + symbol_num*(FFT_num + CP_num);
%% 帧检测
detect_count = 0;
detect_flag = 0;
wrong_flag = 0;

phase_use = 0;
phase_local = randi([120,200]);
frame_lost = 0;

detect_count_plot = zeros(length(msg_In)-2*frame_detect_winth,1);
self_energy1_plot = zeros(length(msg_In)-2*frame_detect_winth,1);
self_energy2_plot = zeros(length(msg_In)-2*frame_detect_winth,1);
cross_energy_plot = zeros(length(msg_In)-2*frame_detect_winth,1);

for n = 1:length(msg_In)-2*frame_detect_winth
    self_energy1 = frame_detect_th*...
                   sum(abs(msg_In(n:n+frame_detect_winth-1)).^2);           %前一段自相关值；
    self_energy2 = frame_detect_th*...
                   sum(abs(msg_In(n+64:n+64+frame_detect_winth-1)).^2);     %后一段自相关值；
    cross_energy = sum(msg_In(n:n+frame_detect_winth-1).*...
                    conj(msg_In(n+64:n+64+frame_detect_winth-1)));          %互相关值；

    if((abs(cross_energy) > self_energy1) && (abs(cross_energy) > self_energy2))
        detect_count = detect_count + 1;
    else
        detect_count = 0;
    end
    
    detect_count_plot(n) = detect_count;
    self_energy1_plot(n) = self_energy1;
    self_energy2_plot(n) = self_energy2;
    cross_energy_plot(n) = abs(cross_energy);

    if(detect_count == detect_count_phase)
        if((~detect_flag) && (~wrong_flag))
            phase_use = angle(cross_energy)/pi/64;
            phase_local = n;
        end
    end

    if(detect_count == detect_count_max)
        detect_flag = 1;
        wrong_flag = 0;
    end

    if(detect_count == detect_worng_max)
        detect_flag = 0;
        wrong_flag = 1;
    end
end

if(detect_flag)
    frame_lost = 1;
end

if(wrong_flag)
    frame_lost = 2;
end

%% 帧检测画图
% figure;
% subplot(2,1,1);
% plot(detect_count_plot);
% title('帧检测计数值');
% subplot(2,1,2);
% plot(self_energy1_plot);
% hold on;
% plot(self_energy2_plot);
% hold on;
% plot(cross_energy_plot);
% legend('前段自相关','后段自相关','互相关');
% title('帧检测能量值')
%% 粗频偏估计
phase_correct = (1:data_length)*phase_use;

start_local = phase_local-correct_local;

% msg_coarse_CFO = [msg_In(1:start_local),...
%                   msg_In(start_local+1:start_local+data_length)...
%                   .*exp(1i*phase_correct * pi),...
%                   msg_In(start_local+data_length+1:end)];
msg_Out = round(msg_In);
%% 粗频偏画图
% msg_In_block = reshape(msg_In(start_local+pream_length+1:...
%                         start_local+data_length),CP_num+FFT_num,symbol_num);
% msg_In_block_ifft = fft(msg_In_block(CP_num+1:end,:),FFT_num);
% scatterplot(reshape(msg_In_block_ifft(data_Sub,:),[],1));
% title('粗频偏前星座图');
% msg_Out_block = reshape(msg_Out(start_local+pream_length+1:...
%                         start_local+data_length),CP_num+FFT_num,symbol_num);
% msg_Out_block_ifft = fft(msg_Out_block(CP_num+1:end,:),FFT_num);
% scatterplot(reshape(msg_Out_block_ifft(data_Sub,:),[],1));
% title('粗频偏后星座图');
end