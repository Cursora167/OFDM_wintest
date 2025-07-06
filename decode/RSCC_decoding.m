function [decode_output]=RSCC_decoding(source,code_rate,soft_en)  % RS-CC����ˣ�����soft_en=1ʱΪ������
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
            [~,ucode_quant] = quantiz(source, 0.5, [0 1]);    % ���ڽ��ʱû�о�������Ӳ�о�ǰ��һ���о�               
            % Unpacket   
            qcode = ucode_quant;
            %qcode = 1-ucode_quant; % ���Ա任
            DI_result = interleaver(qcode,2,32); % �⽻֯
            CC_De = CC_decode(DI_result,2/3,soft_en); % CC���� 
            RS_De = RS_decode(CC_De,3/4); % RS����
            DR_result = randomization(RS_De,2); % ������                
            decode_output = DR_result; % �������
        elseif(soft_en == 1)
            % Unpacket
            %qcode = 2*source-1;                    
            qcode = -1*source; % �������о�ʱҪ����˫�����룬�����ʱ�Ѿ�˫���Ի����ʴ����������Է�ת
            DI_result = interleaver(qcode,2,32); % �⽻֯
            CC_De = CC_decode(DI_result,2/3,soft_en); % CC���� 
            RS_De = RS_decode(CC_De,3/4); % RS����
            DR_result = randomization(RS_De,2); % ������                
            decode_output = DR_result; % �������                
        end
        
    elseif code_rate==3/4
        if (soft_en == 0)
            % Adapter
            [~,ucode_quant] = quantiz(source, 0.5, [0 1]);    % ���ڽ��ʱû�о�������Ӳ�о�ǰ��һ���о�   
            % Unpacket
            qcode = ucode_quant;
            %qcode = 1-ucode_quant; % ���Ա任
            DI_result = interleaver(qcode,2,32); % �⽻֯
            CC_De = CC_decode(DI_result,5/6,soft_en); % CC���� 
            RS_De = RS_decode(CC_De,9/10); % RS����
            DR_result = randomization(RS_De,2); % ������                
            decode_output = DR_result; % �������               
        elseif(soft_en == 1)
            % Unpacket
            qcode = -1*source; % �������о�ʱҪ����˫�����룬�����ʱ�Ѿ�˫���Ի����ʴ����������Է�ת
            DI_result = interleaver(qcode,2,32); % �⽻֯
            CC_De = CC_decode(DI_result,5/6,soft_en); % CC���� 
            RS_De = RS_decode(CC_De,9/10); % RS����
            DR_result = randomization(RS_De,2); % ������                
            decode_output = DR_result; % �������       
        end
    end
end