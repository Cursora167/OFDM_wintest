function [output] = randomization(msg, mode) %modeΪ1��Ϊ���룬Ϊ2��Ϊ�����룬���������򱣳�ԭ�����������
    msgLength = length(msg);
    
    % ��M��������ѭ������
    M = [0,0,0,0,0,0,0,1,0,1,0,1,0,0,1];
    mLength = length(M);
    RoopM = zeros(msgLength,mLength);
    RoopM(1,:) = M;
    for j = 2 : msgLength
        RoopM(j,:) = circshift(RoopM(j-1,:),[0,1]);
        RoopM(j,1) = bitxor(RoopM(j-1,15),RoopM(j-1,14));
    end
    
    if(mode == 1)    % ����     
        Random_out = zeros(1,msgLength);
        for i = 1 : msgLength
            Random_out(i) = bitxor( msg(i) , bitxor(RoopM(i,15),RoopM(i,14)) );
        end
        output = Random_out';
        
    elseif(mode == 2)   % ������ ����ʵ��������һ���Ĺ��̣�
        Derandom_out = zeros(1,msgLength);
        for i = 1 : msgLength
            Derandom_out(i) = bitxor( msg(i) , bitxor(RoopM(i,15),RoopM(i,14)) );
        end
        output = Derandom_out';        
        
    else
        output = msg;
    end

end