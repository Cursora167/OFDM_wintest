function [decode_output]=RSCC_decoding(source,code_rate,soft_en)  % RS-CC译码核，其中soft_en=1时为软译码
    if code_rate==1
        if(soft_en == 0)
            [~,ucode_quant] = quantiz(source, 0, [0 1]); 
            decode_output = ucode_quant';            
        elseif(soft_en == 1)
            [~,ucode_quant] = quantiz(source, 0, [0 1]); 
            decode_output = (1 - ucode_quant)';
        end        
    elseif code_rate==1/2
        if(soft_en == 0)
            % Adapter
            [~,ucode_quant] = quantiz(source, 0.5, [0 1]);    % 由于解调时没判决，故在硬判决前加一级判决               
            % Unpacket   
            qcode = ucode_quant;
            %qcode = 1-ucode_quant; % 极性变换
            DI_result = interleaver(qcode,2,32); % 解交织
            CC_De = CC_decode(DI_result,2/3,soft_en); % CC译码 
            RS_De = RS_decode(CC_De,3/4); % RS译码
            DR_result = randomization(RS_De,2); % 解扰码                
            decode_output = DR_result; % 译码输出
        elseif(soft_en == 1)
            % Unpacket
            %qcode = 2*source-1;                    
            qcode = -1*source; % 采用软判决时要输入双极性码，但解调时已经双极性化，故次数仅做极性反转
            DI_result = interleaver(qcode,2,32); % 解交织
            CC_De = CC_decode(DI_result,2/3,soft_en); % CC译码 
            RS_De = RS_decode(CC_De,3/4); % RS译码
            DR_result = randomization(RS_De,2); % 解扰码                
            decode_output = DR_result; % 译码输出                
        end
        
    elseif code_rate==3/4
        if (soft_en == 0)
            % Adapter
            [~,ucode_quant] = quantiz(source, 0.5, [0 1]);    % 由于解调时没判决，故在硬判决前加一级判决   
            % Unpacket
            qcode = ucode_quant;
            %qcode = 1-ucode_quant; % 极性变换
            DI_result = interleaver(qcode,2,32); % 解交织
            CC_De = CC_decode(DI_result,5/6,soft_en); % CC译码 
            RS_De = RS_decode(CC_De,9/10); % RS译码
            DR_result = randomization(RS_De,2); % 解扰码                
            decode_output = DR_result; % 译码输出               
        elseif(soft_en == 1)
            % Unpacket
            qcode = -1*source; % 采用软判决时要输入双极性码，但解调时已经双极性化，故次数仅做极性反转
            DI_result = interleaver(qcode,2,32); % 解交织
            CC_De = CC_decode(DI_result,5/6,soft_en); % CC译码 
            RS_De = RS_decode(CC_De,9/10); % RS译码
            DR_result = randomization(RS_De,2); % 解扰码                
            decode_output = DR_result; % 译码输出       
        end
    end
end