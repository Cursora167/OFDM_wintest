function [output] = randomization(msg, mode) %mode为1则为扰码，为2则为解扰码，其他数字则保持原本的数据输出
    msgLength = length(msg);
    
    % 由M序列生成循环矩阵
    M = [0,0,0,0,0,0,0,1,0,1,0,1,0,0,1];
    mLength = length(M);
    RoopM = zeros(msgLength,mLength);
    RoopM(1,:) = M;
    for j = 2 : msgLength
        RoopM(j,:) = circshift(RoopM(j-1,:),[0,1]);
        RoopM(j,1) = bitxor(RoopM(j-1,15),RoopM(j-1,14));
    end
    
    if(mode == 1)    % 扰码     
        Random_out = zeros(1,msgLength);
        for i = 1 : msgLength
            Random_out(i) = bitxor( msg(i) , bitxor(RoopM(i,15),RoopM(i,14)) );
        end
        output = Random_out';
        
    elseif(mode == 2)   % 解扰码 （其实和扰码是一样的过程）
        Derandom_out = zeros(1,msgLength);
        for i = 1 : msgLength
            Derandom_out(i) = bitxor( msg(i) , bitxor(RoopM(i,15),RoopM(i,14)) );
        end
        output = Derandom_out';        
        
    else
        output = msg;
    end

end