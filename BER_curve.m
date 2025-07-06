BER = mean(bit_err)/data_num;
BER_qpsk_theory=berawgn(SNR_dB-10*log10(2),'psk',4,'nondiff');                 %AWGN信道下QPSK调制理论误码率
figure;
semilogy(SNR_dB,BER_qpsk_theory,'k--');                                        %QPSK下理论误码曲线
hold on;
semilogy(SNR_dB,BER,'r-s');                                                    %仿真所得到的曲线
axis([min(SNR_dB) max(SNR_dB) 10^(-6) 1]);
grid on;
xlabel('SNR [dB]');
ylabel('BER');