clear;
%% 初始化参数
sim_mode = 0;                                                               %0：Matlab仿真；
                                                                            %1：Vivado数据仿真;                                                                            
read_mode = 0;                                                              %0：CSV文件；
                                                                            %1：TXT文件；
file1 = '.\ila_data_csv\iladata_r1.csv';                                    %csv时只需一个文件；
file2 = '.\vivado_data_txt\data_im.txt';                                    %txt时一个放实部，一个放虚部
parameter;

addpath(genpath('.\encode'));
addpath(genpath('.\decode'));
if(sim_mode == 0)
%% 纯Matlab仿真
    for frameIndex = 1 : sim_loop
        fprintf('仿真共%d帧，第%d帧\n',sim_loop,frameIndex);
        transmitter;
        for SNR_index = 1:length(SNR_dB)
            fprintf('信噪比%.2fdB\n',SNR_dB(SNR_index));
            channel;
            receiver;
        end
    end
   BER_curve;
else
%% 读取数据仿真
    msg_rx = data_read(read_mode,file1,file2);
    receiver;
end

%% 输出txt给vivado读入例程
% fid = fopen('./vivado_sim_rd/msg_rx_re.txt','w');
% fprintf(fid,'%16x\r\n',typecast(int16(real(msg_rx(1:end))),'uint16'));
% fclose(fid);
% fid = fopen('./vivado_sim_rd/msg_rx_im.txt','w');
% fprintf(fid,'%16x\r\n',typecast(int16(imag(msg_rx(1:end))),'uint16'));
% fclose(fid);
