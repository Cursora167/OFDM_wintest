function [output] = RS_encode(input,codeRate) %RS编码器 239_255，第二维参数表示编码后的长度
    
    % 码长信息
    inputL = length(input); % 编码前码长
    codeL = inputL/codeRate; % 编码后码长
    
    % Basic parameteRS for RS Coding
    genPloy = [1,0,1,0,1,1,0,1,0,1,0,0,1,1,0,0,1;
               1,0,0,0,0,1,0,0,0,1,1,0,1,1,0,1,0;
               1,1,0,1,0,1,0,0,0,0,1,0,1,1,1,1,0;
               1,1,0,0,0,0,1,0,1,1,1,1,1,0,0,0,0;
               0,0,1,0,1,1,1,1,0,1,1,0,1,0,1,1,0;
               0,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,0;
               1,0,1,1,0,0,0,0,1,0,1,1,0,1,0,1,0;
               0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0,0;];
             % 生成多项式对应：79,44,81,100,49,183,56,17,232,187,126,104,31,103,52,118,1
             % RS编码参数（本原多项式及生成多项式）可以通过指令RSgenpoly(255,239)得到
             % 
    RS_m = 8; % Number of bits pemr symbol in each codeword 对应GF(2^8)
    RS_t = 8 ; % Error-correction capability 表征RS码纠错能力，239 + 2*RS_t = 255
    shortLength = 0; % 编码缩短长度
    RS_n = 2^RS_m-1-shortLength; RS_k = RS_n-2*RS_t; % Message length and codeword length 编码长度（编成255*8）
    
    %查看是否需要补0，补到RS_k*8
    if rem(length(input),RS_n)>0
        msg=[input ; zeros( (RS_k*RS_m - length(input)) , 1)];
    end
    
    % encode 编码
    msg_reshapeT = (reshape(msg,RS_m,RS_k))';  
    msg_reshape = fliplr(msg_reshapeT); % 对调高低位，以和VIVADO数据对齐
    check_reg = zeros(8,2*RS_t);
    for i =1:RS_k
        mult_result = RS_adder(check_reg(:,2*RS_t),msg_reshape(i,:)');
        for j=2*RS_t:-1:2
            check_reg(:,j) = RS_adder(RS_multiplier(mult_result,genPloy(:,j)),check_reg(:,j-1));
        end
        check_reg(:,1) = RS_multiplier(mult_result,genPloy(:,1));
    end
    code_result = [msg;reshape(rot90(check_reg,2),RS_t*2*8,1)]; %进行一些矩阵翻转运算，以和VIVADO数据对齐
    %code_result = [msg;reshape(fliplr(flipud(check_reg)),RS_t*2*8,1)]; 
    
    % 取RS编码中的信息位位数inputL*8以及校验位前几位*8；如果校验位数超过最大的16*8，则在编码时加多余的零以满足码率的要求
    if((codeL-inputL) <= (16*8))
        output = [code_result(1:inputL) ; code_result(1913:1912+codeL-inputL,1)];
    else
        output = [code_result(1:inputL) ; code_result(1913:2040,1) ; zeros((codeL-inputL-128),1)];
    end
end