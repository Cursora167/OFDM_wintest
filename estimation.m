function msg_Out = estimation(msg_In,symbol_num,FFT_num,data_Sub)
%% 均衡
msg_pream = msg_In(:,1);
msg_data = msg_In(:,2:end);

msg_pream_am = abs(msg_pream);                                              %前导幅度值
msg_pream_ph = angle(msg_pream)/pi;                                         %前导相位值

pream_am = zeros(FFT_num,1);
pream_ph = zeros(FFT_num,1);

pream_chal =load('.\nonzero_num.txt');
pream_ph_theroy = load('.\preamlong_ph_theroy.txt');

pream_ph(pream_chal) = msg_pream_ph(pream_chal) - pream_ph_theroy(pream_chal);

for i =1:256                                                                        
    if pream_ph(i) > 1
        pream_ph(i) = pream_ph(i) - 2;
    end
    if pream_ph(i) <-1 
        pream_ph(i) = pream_ph(i) + 2;
    end    
end

for i =3:2:253
    if pream_ph(i)*pream_ph(i+2)<0
        if pream_ph(i)>0
            if pream_ph(i+2)<pream_ph(i)-1
                pream_ph(i+1)=(pream_ph(i)+pream_ph(i+2))/2+1;
            else
                pream_ph(i+1)=(pream_ph(i)+pream_ph(i+2))/2;
            end
        end
        if pream_ph(i)<0
            if pream_ph(i+2)>pream_ph(i)+1
                pream_ph(i+1)=(pream_ph(i)+pream_ph(i+2))/2+1;
            else
                pream_ph(i+1)=(pream_ph(i)+pream_ph(i+2))/2;
            end
        end
    else
        pream_ph(i+1)=(pream_ph(i)+pream_ph(i+2))/2;
    end
end

pream_ph(2) = pream_ph(3) + 0.0625;
pream_ph(256) = pream_ph(255) - 0.0625;

for i =1:256                                                                        
    if pream_ph(i) > 1
        pream_ph(i) = pream_ph(i) - 2;
    end
    if pream_ph(i) <-1 
        pream_ph(i) = pream_ph(i) + 2;
    end    
end

pream_am(pream_chal) = round(msg_pream_am(pream_chal));
pream_am(4:2:254) = (pream_am(3:2:253)+pream_am(5:2:255))/2;
pream_am(2) = pream_am(3);
pream_am(102) = 0;
pream_am(156) = 0;
pream_am(256) = pream_am(255);
pream_am = round((pream_am)/32);

data_ph = angle(msg_data)/pi;
data_am = round(abs(msg_data))*256;

ph_correct = data_ph - kron(pream_ph,ones(1,symbol_num));
am_correct = round(data_am./kron(pream_am,ones(1,symbol_num)));

msg_equalized = exp(1i*pi*ph_correct).*am_correct;

msg_Out = round(msg_equalized);
%% 画图
% scatterplot(reshape(msg_In(data_Sub,2:end),[],1));
% title('均衡前星座图');
% scatterplot(reshape(msg_Out(data_Sub,:),[],1));
% title('均衡后星座图');
end