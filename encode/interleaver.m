function [output] = interleaver(msg, mode, DataPulseLength) %mode为1则为交织，为2则为解交织，其他数字则保持原本的数据输出
    
    CodeSigLength = length(msg);
    InterDeep = CodeSigLength/DataPulseLength; % InterDeep为交织深度（即矩阵行数），（DataPulseLength为矩阵列数）
    % 行进列出，定义列出的顺序
    pVector = [1 17 9 25 5 21 13 29 3 19 11 27 7 23 15 31 0 16 8 24 4 20 12 28 2 18 10 26 6 22 14 30]'+1; 
    
    if(mode == 1)    %交织                      
        for InterIndex = 1:InterDeep
            InterSigIn(InterIndex ,:) = msg((InterIndex-1)*DataPulseLength+1:InterIndex*DataPulseLength);
        end
        for RowIndex = 1:DataPulseLength
            RowSigIn(:,pVector(RowIndex)) = InterSigIn(:,RowIndex);
        end
        InterSigOut0 = reshape(RowSigIn,1,CodeSigLength);
        output = InterSigOut0';
        
    elseif(mode == 2)   %解交织
        DeInterDataIn = reshape(msg,InterDeep,DataPulseLength); 
        for RowIndex = 1:DataPulseLength
            DeRowSigIn(:,RowIndex)= DeInterDataIn(:,pVector(RowIndex));
        end        
        for InterIndex = 1:InterDeep
            DeInterDataOut0((InterIndex-1)*DataPulseLength+1:DataPulseLength*InterIndex)=DeRowSigIn(InterIndex ,:) ;
        end
        output = DeInterDataOut0';
        
    else
        output = msg;
    end

end