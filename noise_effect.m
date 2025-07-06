function msg_Out = noise_effect(msg_In,SNR_dB)
%根据信噪比添加噪声
    SNR_value = 10.^(SNR_dB/10);
    msg_length = length(msg_In);
    data_length = nnz(msg_In);
    
    msg_power = abs(conj(msg_In)*(msg_In.'))/data_length;
    noise_power = msg_power/SNR_value;
    noise = (randn(1,msg_length)+1i*randn(1,msg_length)).*sqrt(noise_power/2);
 
    msg_Out = round(msg_In + noise);

end