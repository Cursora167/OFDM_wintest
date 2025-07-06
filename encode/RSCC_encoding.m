function [encode_output]=RSCC_encoding(source,code_rate,data_num) %编码器核心

if code_rate==1
    encode_output=source;
elseif code_rate==1/2
    % Create a message to be encoded.
    msg = source; 
    RN_result = randomization(msg,1); % 交织
    RS_Co = RS_encode(RN_result,3/4); % RS编码
    CC_Co = CC_encode(RS_Co,2/3); % CC译码
    IR_result = interleaver(CC_Co,1,32); % 交织  
    % Package
    encode_output = [IR_result;zeros(data_num-length(IR_result),1)];
elseif code_rate==3/4
    % Create a message to be encoded.
    msg = source;  
    RN_result = randomization(msg,1); % 交织
    RS_Co = RS_encode(RN_result,9/10); % RS编码
    CC_Co = CC_encode(RS_Co,5/6); % CC译码
    IR_result = interleaver(CC_Co,1,32); % 交织                     
   % Package
    encode_output = [IR_result;zeros(data_num-length(IR_result),1)];
end

end
