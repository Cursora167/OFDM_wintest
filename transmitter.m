%% 信源
msg_source = randi([0 1],data_num,1);
%% 编码
msg_encode = RSCC_core(msg_source,code_mode,0,data_num/symbol_num);
%% 调制
msg_module = tran_module(msg_encode,module_mode,symbol_num, ...
                        FFT_num,pilot_Sub,pilot_sym,data_Sub);
%% ifft
msg_ifft = tran_ifft(msg_module,FFT_num,CP_num);
%% 组帧
msg_blank = zeros(1,200);
%msg_blank = zeros(1,1000);
msg_frame = [msg_blank,pream,reshape(msg_ifft.',1,[]),msg_blank];
%msg_tx = conv(upsample(msg_frame,8),cosine_filter);
msg_tx = msg_frame;
short_pream = pream(1:294);
long_pream = pream(295:588);
% OFDM信号Overlap-Add加窗处理
% 信号结构说明：
% msg_blank: 空白段（上下文静默区，两端全为0，长度 100–500 可变）
% short_pream: 短前导符号（长度 256+CP）
% long_pream: 长前导符号（长度 256+CP）
% msg_ifft: 大小 8×(256+CP) 的矩阵，每行为一个 OFDM 符号（含 38 点 CP）
% 信号总结构： [msg_blank, short_pream, long_pream, msg_ifft(1,:), …, msg_ifft(8,:), msg_blank]
EYY;
Overlap_Add;

Ho = filtertest;
msg_filter = filter(Ho,msg_tx);
% 频域图(降采样)
% V_FFT = 500000;
% figure;
% msg_tx_freq = 10*log10(abs(fftshift(fft(msg_filter,V_FFT))));
% V_Freq = 0 : fb/V_FFT : fb-fb/V_FFT;
% plot(V_Freq,msg_tx_freq);
% 
% fvtool(Ho)


%% 画图
%发射信号频域图
V_FFT = 500000;
figure;
msg_tx_freq = 10*log10(abs(fftshift(fft(windowed_signal(200+294*2+1:200+294*3),V_FFT))));
V_Freq = 0 : fb/V_FFT : fb-fb/V_FFT;
plot(V_Freq,msg_tx_freq);
% msg_tx = msg_tx(1551:3902);
% figure;
% t_tx = 0:1/fs:(length(msg_tx)-1)/fs;
% subplot(2,1,1)
% plot(t_tx,real(msg_tx));
% title('发送信号实部');
% subplot(2,1,2)
% plot(t_tx,imag(msg_tx));
% title('发送信号虚部');
%发射信号频域图
V_FFT = 500000;
figure;
msg_tx_freq = 10*log10(abs(fftshift(fft(msg_tx,V_FFT))));
V_Freq = 0 : fb/V_FFT : fb-fb/V_FFT;
plot(V_Freq,msg_tx_freq);
% %% 滤波器设计
% Hd = filterx;
% Hc = filtery;
% %fvtool(Hd);
% 
% %插值 ×2（上采样）
% interp_factor = 2;
% msg_tx_up = upsample(msg_tx, interp_factor);  % 插值上采样，频谱压缩
% msg_filter = filter(Hd,msg_tx_up);
% % 频域图（上采样）
% % V_FFT = 500000;
% % figure;
% % msg_tx_freq = 10*log10(abs(fftshift(fft(msg_tx_up,V_FFT))));
% % V_Freq = 0 : 2*fb/V_FFT : 2*fb-2*fb/V_FFT;
% % plot(V_Freq,msg_tx_freq);
% % 频域图（低通）
% % V_FFT = 500000;
% % figure;
% % msg_tx_freq = 10*log10(abs(fftshift(fft(msg_filter,V_FFT))));
% % V_Freq = 0 : 2*fb/V_FFT : 2*fb-2*fb/V_FFT;
% % plot(V_Freq,msg_tx_freq);
% 
% 
% 
% msg_filter_sec = filter(Hc,msg_filter);
% %频域图（抗混叠）
% % V_FFT = 500000;
% % figure;
% % msg_tx_freq = 10*log10(abs(fftshift(fft(msg_filter_sec,V_FFT))));
% % V_Freq = 0 : 2*fb/V_FFT : 2*fb-2*fb/V_FFT;
% % plot(V_Freq,msg_tx_freq);
% 
% 
% %抽样 /2 (降采样)
% decimation_factor = 2;
% msg_tx_down = 2*downsample(msg_filter_sec, decimation_factor);
% % % 频域图(降采样)
% % V_FFT = 500000;
% % figure;
% % msg_tx_freq = 10*log10(abs(fftshift(fft(msg_tx_down,V_FFT))));
% % V_Freq = 0 : fb/V_FFT : fb-fb/V_FFT;
% % plot(V_Freq,msg_tx_freq);

