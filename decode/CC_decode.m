function [decodingOut] = CC_decode(decode_in,convCodeRate,quantMode) %quantMode=0 Ӳ�о���quantMode=1 ����������quantMode=2 3-bit���о�
    
    %��������
    if(convCodeRate==2/3)               %2/3����
        %blockLength = 170;              %�鳤
        punctureVector = [1 1 0 1];     
    else                                %5/6����
        %blockLength = 320;             %�鳤
        punctureVector = [1 1 0 1 1 0 0 1 1 0];
    end
    generateVector =[1 1 1 1 0 0 1;1 0 1 1 0 1 1];
    
    gVectorL = length(generateVector(1,:))-1; % �Ĵ����ĸ�����Ϊ�����ɶ���ʽ��ά��-1��
    punctureIndex = find(punctureVector>0);   % ����׵ı�������
    pNonzeroL = length(punctureIndex);        % δ��׸���
    pTotalL = length(punctureVector);         % ����׸���+δ��׸������ܺ�
    
    % ����Ϊ�����룬��Ҫ��������(2*�Ĵ�������*����)��0
    ucode_quant = [decode_in;zeros( ceil(2*(gVectorL)*(pNonzeroL/pNonzeroL)) , 1 ) ];
    % ���������������ȣ�������ʵ����������+�Ĵ�������(6)
    decodeL = length(decode_in)*convCodeRate+gVectorL;    
    
    % ����Ϊ[171,133]��6λ�Ĵ�������->64������Ӧ���������
    % ����ת�ƹ�ϵ����
    transMatrix = zeros(64,4);
    for i = 1:64
        data_bin=int2bin(i-1);
        transMatrix(i,1)=mod([data_bin;0].'*generateVector(1,:)',2);
        transMatrix(i,2)=mod([data_bin;0].'*generateVector(2,:)',2);
        transMatrix(i,3)=mod([data_bin;1].'*generateVector(1,:)',2);
        transMatrix(i,4)=mod([data_bin;1].'*generateVector(2,:)',2);
    end
    % ��֧������Ԫ
    if(quantMode == 0)
        mapVector = [0  1];
    elseif (quantMode == 1)
        mapVector = [-10 10];
    else
        mapVector = [3 -4];
    end
    branchMetric = [abs(mapVector(1)-ucode_quant),abs(mapVector(2)-ucode_quant)];
    %ȥ��ײ���
    branchMetricWoPunc = zeros(decodeL*2,2);
    index = 1 : decodeL*2/pTotalL;
    for i = 1:length(index)
        branchMetricWoPunc( (pTotalL*(i-1)+punctureIndex) , :) = branchMetric( (pNonzeroL*(i-1)+1 : pNonzeroL*i) , :);  
    end
    % �ӱ�ѡ��Ԫ �о����Decision
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
    % �������루�����룩
    decodingOutTmp = zeros(decodeL+6,1);
    for i = decodeL:-1:1;
        decodingOutTmp(i,1) = decision(bin2int(decodingOutTmp(i+6:-1:i+1))+1,i);
    end
    decodingOut = decodingOutTmp(7:decodeL);%�������������
    
end