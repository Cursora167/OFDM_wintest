%% 参数
channel_sel = 0;                                                            %信道选择
freq_offset = 0;                                                            %频偏，Hz
time_offset = 0;                                                            %时偏，us
%% 信道
msg_channel = channel_effect(msg_filter,channel_sel,freq_offset,time_offset,fs);
%% 添加噪声
% msg_noise = msg_channel;
%msg_match = conv(msg_channel,cosine_filter);
%msg_downsample = msg_match(49:8:end);
msg_rx = noise_effect(msg_channel,SNR_dB(SNR_index));