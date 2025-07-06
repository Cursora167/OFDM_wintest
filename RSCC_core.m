function [code_output]=RSCC_core(source,code_mode,en_or_de,sub_data_num)    %RS-CC������ en_or_de��ʾ���뻹������

switch code_mode
    case 0
        code_rate = 1;
    case 1
        code_rate = 1/2;
    case 2
        code_rate = 3/4;
end

if(en_or_de==0)
        sourceLength = length(source);
        code_output = [];
        if code_rate==1  %��Ӧ�ޱ���
            code_output=RSCC_encoding(source,code_rate,floor(sourceLength/code_rate));
        elseif(code_rate==1/2 || code_rate==3/4)
            repeat_num = floor(sourceLength/sub_data_num);
            for i =1 : repeat_num
                code_output_once=RSCC_encoding(source(1+(i-1)*sub_data_num:i*sub_data_num),code_rate,sub_data_num);
                code_output = [code_output;code_output_once];
            end
        end
        
    elseif(en_or_de==1)
        soft_en = 1;
        demodSigLength = length(source);
        coded_sub_data_num = sub_data_num/code_rate;
        % msg = msg/sqrt(msg'*msg/demodSigLength); %��һ��
        code_output = [];
        if code_rate==1  %��Ӧ�ޱ���
            code_output=RSCC_decoding(source,code_rate,soft_en);        
        elseif(code_rate==1/2 || code_rate==3/4)    
            repeat_num = floor(demodSigLength/coded_sub_data_num);            
            for i =1 : repeat_num                                        %�����յ������ݰ�����Ҫ�Ŀ鳤�ȷֿ�����
                code_output_once=RSCC_decoding(source(1+(i-1)*coded_sub_data_num:i*coded_sub_data_num),code_rate,soft_en);
                code_output = [code_output;code_output_once];
            end    
        end
    end
end