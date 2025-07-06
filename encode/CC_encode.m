 function [convCodeOut] = CC_encode(code_in,convCodeRate)%��������ģ��
    % ����ǰ���ֳ���
    codeL = length(code_in);
 
    %�������ü���0����
    if(convCodeRate==2/3)               % ��Ӧ1/2����
        dataInCC = code_in;
        %blockLength = 170;
        punctureVector = [1 1 0 1];     % ��Ӧ2/3���ʵ�ɾ�ࣨ��ף�ʸ��10��11�����ν������У���171-10��133-11��
    else                                % ��Ӧ5/6����
        dataInCC = code_in;
        %blockLength = 320;
        punctureVector = [1 1 0 1 1 0 0 1 1 0]; % ��Ӧ5/6���ʵ�ɾ�ࣨ��ף�ʸ��10101��11010�����ν������У�
    end
    generateVector =[1 1 1 1 0 0 1;1 0 1 1 0 1 1]; %�˽��ƶ�ӦΪ��171��133����171(X)��133(Y)�����������
    
    % �������
    convCodeOut_X = mod(conv(dataInCC,generateVector(1,:)),2);
    convCodeOut_Y = mod(conv(dataInCC,generateVector(2,:)),2);
    convCodeOut_X = convCodeOut_X((1:(length(convCodeOut_X)-6)),1);
    convCodeOut_Y = convCodeOut_Y((1:(length(convCodeOut_Y)-6)),1);
    convCodeOut_Orig = reshape([convCodeOut_X,convCodeOut_Y]',1,2*length(convCodeOut_Y))';
    convCodeOut = zeros(codeL/convCodeRate,1);
    % ɾ�ࣨ��ף�����
    punctureIndex = find(punctureVector>0);
    pZeroL = length(punctureVector);
    pNonzeroL = length(punctureIndex);    
    for i = 1:floor(length(convCodeOut_Orig)/length(punctureVector))
        convCodeOut( pNonzeroL*(i-1)+1 : pNonzeroL*i , :) = convCodeOut_Orig( pZeroL*(i-1)+punctureIndex , :);
    end
end