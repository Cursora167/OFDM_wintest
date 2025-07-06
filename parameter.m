%%
sim_loop = 10;                                                           %仿真次数；
SNR_dB = 0:1:15;                                                              %信噪比；
CP_num = 38;                                                                %CP点数；
FFT_num = 256;                                                              %FFT点数
fb = 11.2*1e6;                                                             %基带速率；
fs = 8*fb;                                                                  %采样率；
fc = 582*1e6;                                                              %载波频率；
cosine_filter=[rcosdesign(0.5,6,8,"sqrt")].';                               %成形滤波器；

bit_err = zeros(sim_loop,length(SNR_dB));
frame_lost = zeros(sim_loop,length(SNR_dB));
EVM = zeros(sim_loop,length(SNR_dB));
%% 帧结构
symbol_num = 8;                                                             %每帧符号数；
sub_data_num = 192;                                                         %每个符号数据子载波数;
code_mode = 1;                                                              %RSCC 编码码率;  0-无编码  1-1/2  2-3/4；
module_mode = 1;                                                            %调制方式   0-无调制 1-QPSK 2-16QAM 3-64QAM;
data_num =  data_num_cal(symbol_num,sub_data_num,code_mode,module_mode);    %每帧数据量；                                                   
%% 导频
pream = pream_pilot(FFT_num,CP_num);
pilot_base=[-1 +1 -1 +1 -1 -1 -1 -1].';                                     %基本导频
pilot_sym =(kron(pilot_base,(-1).^(0:symbol_num-1)))';                      %数据块整体导频，功率调整成与数据部分相同
%% 载波位置
zero_Sub = [1 102:156];                                                     %零子载波位置
pilot_Sub = [14 39 64 89 169 194 219 244];                                  %导频子载波位置
data_Sub = setdiff(1:256,[zero_Sub pilot_Sub]);                             %数据子载波位置