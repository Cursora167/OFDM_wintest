function [decodingOut] = CC_decode(decode_in,convCodeRate,quantMode) %quantMode=0 硬判决；quantMode=1 浮点量化；quantMode=2 3-bit软判决
    
    %卷积码参数
    if(convCodeRate==2/3)               %2/3码率
        %blockLength = 170;              %块长
        punctureVector = [1 1 0 1];     
    else                                %5/6码率
        %blockLength = 320;             %块长
        punctureVector = [1 1 0 1 1 0 0 1 1 0];
    end
    generateVector =[1 1 1 1 0 0 1;1 0 1 1 0 1 1];
    
    gVectorL = length(generateVector(1,:))-1; % 寄存器的个数，为（生成多项式的维度-1）
    punctureIndex = find(punctureVector>0);   % 不打孔的比特向量
    pNonzeroL = length(punctureIndex);        % 未打孔个数
    pTotalL = length(punctureVector);         % （打孔个数+未打孔个数）总和
    
    % 代码为归零码，需要在输入后加(2*寄存器个数*码率)个0
    ucode_quant = [decode_in;zeros( ceil(2*(gVectorL)*(pNonzeroL/pNonzeroL)) , 1 ) ];
    % 归零码译码结果长度，等于真实译码结果长度+寄存器个数(6)
    decodeL = length(decode_in)*convCodeRate+gVectorL;    
    
    % 以下为[171,133]（6位寄存器个数->64）所对应的译码代码
    % 生成转移关系矩阵
    transMatrix = zeros(64,4);
    for i = 1:64
        data_bin=int2bin(i-1);
        transMatrix(i,1)=mod([data_bin;0].'*generateVector(1,:)',2);
        transMatrix(i,2)=mod([data_bin;0].'*generateVector(2,:)',2);
        transMatrix(i,3)=mod([data_bin;1].'*generateVector(1,:)',2);
        transMatrix(i,4)=mod([data_bin;1].'*generateVector(2,:)',2);
    end
    % 分支度量单元
    if(quantMode == 0)
        mapVector = [0  1];
    elseif (quantMode == 1)
        mapVector = [-10 10];
    else
        mapVector = [3 -4];
    end
    branchMetric = [abs(mapVector(1)-ucode_quant),abs(mapVector(2)-ucode_quant)];
    %去打孔操作
    branchMetricWoPunc = zeros(decodeL*2,2);
    index = 1 : decodeL*2/pTotalL;
    for i = 1:length(index)
        branchMetricWoPunc( (pTotalL*(i-1)+punctureIndex) , :) = branchMetric( (pNonzeroL*(i-1)+1 : pNonzeroL*i) , :);  
    end
    % 加比选单元 判决获得Decision
    decision = zeros(64,decodeL);
    pathMetric = 64*ones(64,1);
    pathMetric(1) = 0;
    pathMetric_new = zeros(64,1);
    puncNum = 1;
    for i = 1:decodeL
       for j =1:64
           pathMetric0 = pathMetric(mod(j-1,32)*2+1) + branchMetricWoPunc(2*i-1,1+transMatrix(j,1)) + branchMetricWoPunc(2*i,1+transMatrix(j,2));
           pathMetric1 = pathMetric(mod(j-1,32)*2+2) + branchMetricWoPunc(2*i-1,1+transMatrix(j,3)) + branchMetricWoPunc(2*i,1+transMatrix(j,4));
           if(pathMetric0>=pathMetric1)
                decision(j,i) = 1;
                pathMetric_new(j) = pathMetric1;
           else
                decision(j,i) = 0;
                pathMetric_new(j) = pathMetric0;
           end
       end
       pathMetric = pathMetric_new;
    end
    % 回溯译码（归零码）
    decodingOutTmp = zeros(decodeL+6,1);
    for i = decodeL:-1:1;
        decodingOutTmp(i,1) = decision(bin2int(decodingOutTmp(i+6:-1:i+1))+1,i);
    end
    decodingOut = decodingOutTmp(7:decodeL);%输出最终译码结果
    
end