function [output] = RS_encode(input,codeRate) %RS������ 239_255���ڶ�ά������ʾ�����ĳ���
    
    % �볤��Ϣ
    inputL = length(input); % ����ǰ�볤
    codeL = inputL/codeRate; % ������볤
    
    % Basic parameteRS for RS Coding
    genPloy = [1,0,1,0,1,1,0,1,0,1,0,0,1,1,0,0,1;
               1,0,0,0,0,1,0,0,0,1,1,0,1,1,0,1,0;
               1,1,0,1,0,1,0,0,0,0,1,0,1,1,1,1,0;
               1,1,0,0,0,0,1,0,1,1,1,1,1,0,0,0,0;
               0,0,1,0,1,1,1,1,0,1,1,0,1,0,1,1,0;
               0,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,0;
               1,0,1,1,0,0,0,0,1,0,1,1,0,1,0,1,0;
               0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0,0;];
             % ���ɶ���ʽ��Ӧ��79,44,81,100,49,183,56,17,232,187,126,104,31,103,52,118,1
             % RS�����������ԭ����ʽ�����ɶ���ʽ������ͨ��ָ��RSgenpoly(255,239)�õ�
             % 
    RS_m = 8; % Number of bits pemr symbol in each codeword ��ӦGF(2^8)
    RS_t = 8 ; % Error-correction capability ����RS�����������239 + 2*RS_t = 255
    shortLength = 0; % �������̳���
    RS_n = 2^RS_m-1-shortLength; RS_k = RS_n-2*RS_t; % Message length and codeword length ���볤�ȣ����255*8��
    
    %�鿴�Ƿ���Ҫ��0������RS_k*8
    if rem(length(input),RS_n)>0
        msg=[input ; zeros( (RS_k*RS_m - length(input)) , 1)];
    end
    
    % encode ����
    msg_reshapeT = (reshape(msg,RS_m,RS_k))';  
    msg_reshape = fliplr(msg_reshapeT); % �Ե��ߵ�λ���Ժ�VIVADO���ݶ���
    check_reg = zeros(8,2*RS_t);
    for i =1:RS_k
        mult_result = RS_adder(check_reg(:,2*RS_t),msg_reshape(i,:)');
        for j=2*RS_t:-1:2
            check_reg(:,j) = RS_adder(RS_multiplier(mult_result,genPloy(:,j)),check_reg(:,j-1));
        end
        check_reg(:,1) = RS_multiplier(mult_result,genPloy(:,1));
    end
    code_result = [msg;reshape(rot90(check_reg,2),RS_t*2*8,1)]; %����һЩ����ת���㣬�Ժ�VIVADO���ݶ���
    %code_result = [msg;reshape(fliplr(flipud(check_reg)),RS_t*2*8,1)]; 
    
    % ȡRS�����е���Ϣλλ��inputL*8�Լ�У��λǰ��λ*8�����У��λ����������16*8�����ڱ���ʱ�Ӷ���������������ʵ�Ҫ��
    if((codeL-inputL) <= (16*8))
        output = [code_result(1:inputL) ; code_result(1913:1912+codeL-inputL,1)];
    else
        output = [code_result(1:inputL) ; code_result(1913:2040,1) ; zeros((codeL-inputL-128),1)];
    end
end