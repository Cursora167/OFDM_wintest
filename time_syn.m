function msg_Out = time_syn(msg_In,frame_start_local,symbol_num,FFT_num,CP_num)
%%定时同步
win_length = 320;                                                           %搜索窗长度；
%本地序列
localSig_Re = flipud([-62,-25,2,-47,-38,-68,7,63,-25,16,24,-45,-8,-31,-82,-64,-36,18,49,7,-10,68,59,-45,-20,21,27,68,72,64,7,0,72,11,-25,-29,-66,39,25,-63,33,73,47,-2,-67,-6,-13,-90,-8,63,-25,-84,-19,-3,-1,45,17,29,76,30,-36,-62,29,51].');
localSig_Im = flipud([45,-45,9,-15,-50,-33,-33,-63,-44,52,9,-47,4,-32,-12,64,56,54,-23,-75,31,39,-12,45,28,-25,52,52,-39,-62,-70,0,54,-1,60,62,-61,-16,65,63,53,33,-9,-51,32,42,-56,-13,-42,-44,71,-23,-41,46,-14,-45,-75,-24,49,-5,55,16,-84,51].');

index = kron((1:64),ones(win_length,1)) + ...
        kron(ones(1,64),(0:win_length-1).') + frame_start_local - 40;        %从帧检测位置附件开始搜索；
index_data_re = sign(real(msg_In(index)));
index_data_re(index_data_re == 0) = 1;
index_data_im = sign(imag(msg_In(index)));
index_data_im(index_data_im == 0) = 1;

Corr_result = zeros(1,win_length);
    Corr_Re = zeros(1,64);
    Corr_Im = zeros(1,64);

for n=1:win_length
    for m=1:64  
        if((index_data_re(n,m)==1) && (index_data_im(n,m)==1))

             Corr_Re(m) = localSig_Re(m) + localSig_Im(m);
             Corr_Im(m) = localSig_Re(m) - localSig_Im(m);

        elseif((index_data_re(n,m)==1) && (index_data_im(n,m)==-1))

             Corr_Re(m) =  localSig_Re(m) - localSig_Im(m);
             Corr_Im(m) = -localSig_Re(m) - localSig_Im(m); 

        elseif((index_data_re(n,m)==-1) && (index_data_im(n,m)==1))

             Corr_Re(m) = -localSig_Re(m) + localSig_Im(m);
             Corr_Im(m) =  localSig_Re(m) + localSig_Im(m); 

        elseif((index_data_re(n,m)==-1) && (index_data_im(n,m)==-1))
             Corr_Re(m) = -localSig_Re(m) - localSig_Im(m);
             Corr_Im(m) = -localSig_Re(m) + localSig_Im(m); 
        end
    end
    Corr_result(n)=abs(sum(Corr_Re))+abs(sum(Corr_Im));
end

Corr_result_peak = Corr_result + [zeros(1,64),Corr_result(1:end-64)]...     %四个同步峰相加
                   + [zeros(1,128),Corr_result(1:end-128)]...
                   + [zeros(1,192),Corr_result(1:end-192)];

find_local = 30+230-32+1:30+230+32;                                         %在第四段短前导附件搜索；                                      
[~,peak_local] = max(Corr_result_peak(find_local));
peak_local = find_local(peak_local) + frame_start_local - 40;

start_local = peak_local  + 64 + CP_num - 8;                                 %8个定时提前；

data_local = kron((0:symbol_num).*(FFT_num + CP_num),ones(1,FFT_num))...
            + kron(ones(1,symbol_num + 1),(start_local : start_local + FFT_num - 1));
msg_Out = msg_In(data_local);
%% 同步峰画图
% figure;
% plot(index(:,1),Corr_result_peak);
% title('捕获窗口的同步峰');
end