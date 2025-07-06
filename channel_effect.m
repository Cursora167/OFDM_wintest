function msg_Out = channel_effect(msg_In,channel_sel,freq_offset,time_offset,fs)
%信道影响 0：AWGN
    chan0 = 1;

    switch channel_sel
        case 0
            msg_channel = conv(chan0,msg_In);
    end
    
    msg_length = length(msg_channel);
 %频偏影响
    phase_offset = zeros(1,msg_length);

    if(freq_offset ~= 0)
        phase_offset = (0:msg_length-1)*freq_offset*2*pi/fs +rand*2*pi;
    end

    msg_freq_off = msg_channel.*exp(1i*phase_offset);
            
  %定时偏差
    if(time_offset == 0)
        sample_time = 1:msg_length;
    else
        sample_time = 1+rand:1+time_offset*10e-6:msg_length;
    end
    
    msg_time_off = interp1(msg_freq_off,sample_time,"spline");

    msg_Out = round(msg_time_off);
end