function msg_Out = fine_CFO(msg_In,symbol_num,FFT_num,CP_num,data_Sub)

% 细频偏估计
long_pream_pre = msg_In(1:128);
long_pream_post = msg_In(129:256);
corralation = sum(long_pream_pre .* conj(long_pream_post));
phase = angle(corralation)/pi/128;

correct_index = kron((0:symbol_num).*(FFT_num + CP_num),ones(1,FFT_num))...
                + kron(ones(1,symbol_num + 1),(2*CP_num + FFT_num + 1 :2*(CP_num + FFT_num)));
phase_correct = correct_index * phase;

msg_fine_CFO = msg_In.*exp(1i * phase_correct * pi);

msg_Out = round(msg_fine_CFO);

%% 画图
% msg_In_block = reshape(msg_In(FFT_num+1:end),FFT_num, symbol_num);
% msg_In_block_ifft = fft(msg_In_block,FFT_num);
% scatterplot(reshape(msg_In_block_ifft(data_Sub,:),[],1));
% title('细频偏前星座图');
% msg_Out_block = reshape(msg_Out(FFT_num+1:end),FFT_num, symbol_num);
% msg_Out_block_ifft = fft(msg_Out_block,FFT_num);
% scatterplot(reshape(msg_Out_block_ifft(data_Sub,:),[],1));
% title('细频偏后星座图');
end