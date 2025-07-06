function msg_Out = tran_ifft(msg_In,FFT_num,CP_num)
% ifft
    msg_ifft_pre = round(ifft(msg_In.',FFT_num).');
    msg_Out = [msg_ifft_pre(:,end-CP_num+1 : end) msg_ifft_pre];
end