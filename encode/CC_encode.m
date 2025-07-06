 function [convCodeOut] = CC_encode(code_in,convCodeRate)%卷积码编码模块
    % 编码前码字长度
    codeL = length(code_in);
 
    %参数设置及补0操作
    if(convCodeRate==2/3)               % 对应1/2码率
        dataInCC = code_in;
        %blockLength = 170;
        punctureVector = [1 1 0 1];     % 对应2/3码率的删余（打孔）矢量10和11（依次交替排列）（171-10；133-11）
    else                                % 对应5/6码率
        dataInCC = code_in;
        %blockLength = 320;
        punctureVector = [1 1 0 1 1 0 0 1 1 0]; % 对应5/6码率的删余（打孔）矢量10101和11010（依次交替排列）
    end
    generateVector =[1 1 1 1 0 0 1;1 0 1 1 0 1 1]; %八进制对应为：171和133（先171(X)后133(Y)，交替输出）
    
    % 卷积编码
    convCodeOut_X = mod(conv(dataInCC,generateVector(1,:)),2);
    convCodeOut_Y = mod(conv(dataInCC,generateVector(2,:)),2);
    convCodeOut_X = convCodeOut_X((1:(length(convCodeOut_X)-6)),1);
    convCodeOut_Y = convCodeOut_Y((1:(length(convCodeOut_Y)-6)),1);
    convCodeOut_Orig = reshape([convCodeOut_X,convCodeOut_Y]',1,2*length(convCodeOut_Y))';
    convCodeOut = zeros(codeL/convCodeRate,1);
    % 删余（打孔）处理
    punctureIndex = find(punctureVector>0);
    pZeroL = length(punctureVector);
    pNonzeroL = length(punctureIndex);    
    for i = 1:floor(length(convCodeOut_Orig)/length(punctureVector))
        convCodeOut( pNonzeroL*(i-1)+1 : pNonzeroL*i , :) = convCodeOut_Orig( pZeroL*(i-1)+punctureIndex , :);
    end
end