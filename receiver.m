%% 接收信号画图
% figure;
% % t_rx = 0:1/fb:(length(msg_rx)-1)/fb;
% t_rx = 1:length(msg_rx);
% subplot(2,1,1)
% plot(t_rx,real(msg_rx));
% title('接收信号实部');
% subplot(2,1,2)
% plot(t_rx,imag(msg_rx));
% title('接收信号虚部');

%% 帧检测与粗频偏估计
if(sim_mode == 0)
    [msg_coarse_CFO,frame_lost(frameIndex,SNR_index),frame_start_local] = ...
    frame_detect(msg_rx,length(pream),symbol_num,FFT_num,CP_num,data_Sub);
else
    [msg_coarse_CFO,frame_lost,frame_start_local] = ...
    frame_detect(msg_rx,length(pream),symbol_num,FFT_num,CP_num,data_Sub);
end

%% 定时同步
msg_time_syn = time_syn(msg_coarse_CFO,frame_start_local,symbol_num,FFT_num,CP_num);
%% 细频偏估计
msg_fine_CFO = fine_CFO(msg_time_syn,symbol_num,FFT_num,CP_num,data_Sub);
%% FFT
msg_fft = round(fft(reshape(msg_fine_CFO,FFT_num,[]),FFT_num));
%% 信道估计/均衡
msg_est = estimation(msg_fft,symbol_num,FFT_num,data_Sub);
%% 相位追踪
msg_PT = phasetrack(msg_est,pilot_sym,pilot_Sub,data_Sub);
%% 解调
msg_demodule = tran_demodule(msg_PT,module_mode);
%% 解码
msg_decode = RSCC_core(msg_demodule,code_mode,1,data_num/symbol_num);
bit_err(frameIndex,SNR_index) = nnz(msg_decode - msg_source);