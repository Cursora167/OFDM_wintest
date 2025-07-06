function Msg_Out = tran_demodule(Msg_In,module_mode)
%调制：0:无调制、1：QOSK、2：16QAM、3：64QAM；


msg_data = reshape(Msg_In,[],1).'; % 调整数据矩阵维度
data_length = 2*length(msg_data);

msg_data_temp = reshape([real(msg_data);imag(msg_data)],1,[]);
msg_demodule = zeros(data_length,3);

for i = 1 : data_length
    if( msg_data_temp(i)>=0 && abs(msg_data_temp(i))<447 )
        msg_demodule(i,1) = + 0.25;  
        msg_demodule(i,2) = + 4;
        msg_demodule(i,3) = - 2;
    elseif( msg_data_temp(i)>=0 && 447<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<1341 )
        msg_demodule(i,1) = + 1;
        msg_demodule(i,2) = + 3;
        msg_demodule(i,3) = - 1;
    elseif( msg_data_temp(i)>=0 && 1341<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<1788 )
        msg_demodule(i,1) = + 2;
        msg_demodule(i,2) = + 2;
        msg_demodule(i,3) = - 0.25;
    elseif( msg_data_temp(i)>=0 && 1788<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<2235 )
        msg_demodule(i,1) = + 2;
        msg_demodule(i,2) = + 2;
        msg_demodule(i,3) = + 0.25;
    elseif( msg_data_temp(i)>=0 && 2235<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<3128 )
        msg_demodule(i,1) = + 3;   
        msg_demodule(i,2) = + 1;
        msg_demodule(i,3) = + 1;
    elseif( msg_data_temp(i)>=0 && 3128<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<3575 )
        msg_demodule(i,1) = + 4;
        msg_demodule(i,2) = + 0.25;
        msg_demodule(i,3) = + 2;
    elseif( msg_data_temp(i)>=0 && 3575<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<4022 )
        msg_demodule(i,1) = + 4;    
        msg_demodule(i,2) = - 0.25;
        msg_demodule(i,3) = + 2;
    elseif( msg_data_temp(i)>=0 && 4022<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<4916 )
        msg_demodule(i,1) = + 5;  
        msg_demodule(i,2) = - 1;
        msg_demodule(i,3) = + 1;
    elseif( msg_data_temp(i)>=0 && 4916<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<5363 )
        msg_demodule(i,1) = + 6;    
        msg_demodule(i,2) = - 2;
        msg_demodule(i,3) = + 0.25;
    elseif( msg_data_temp(i)>=0 && 5363<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<5810 )
        msg_demodule(i,1) = + 6;   
        msg_demodule(i,2) = - 2;
        msg_demodule(i,3) = - 0.25;
    elseif( msg_data_temp(i)>=0 && 5810<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<6704 )
        msg_demodule(i,1) = + 7;   
        msg_demodule(i,2) = - 3;
        msg_demodule(i,3) = - 1;
    elseif( msg_data_temp(i)>=0 && 6704<=abs(msg_data_temp(i)) )
        msg_demodule(i,1) = + 7;  
        msg_demodule(i,2) = - 4;
        msg_demodule(i,3) = - 2;
    elseif( msg_data_temp(i)<0 && abs(msg_data_temp(i))<447 )
        msg_demodule(i,1) = - 0.25;   
        msg_demodule(i,2) = + 4;
        msg_demodule(i,3) = - 2;                    
    elseif( msg_data_temp(i)<0 && 447<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<1341 )
        msg_demodule(i,1) = - 1;
        msg_demodule(i,2) = + 3;
        msg_demodule(i,3) = - 1;                    
    elseif( msg_data_temp(i)<0 && 1341<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<1788 )
        msg_demodule(i,1) = - 2;
        msg_demodule(i,2) = + 2;
        msg_demodule(i,3) = - 0.25;                    
    elseif( msg_data_temp(i)<0 && 1788<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<2235 )
        msg_demodule(i,1) = - 2;
        msg_demodule(i,2) = + 2;
        msg_demodule(i,3) = + 0.25;
    elseif( msg_data_temp(i)<0 && 2235<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<3128 )
        msg_demodule(i,1) = - 3;   
        msg_demodule(i,2) = + 1;
        msg_demodule(i,3) = + 1;
    elseif( msg_data_temp(i)<0 && 3128<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<3575 )
        msg_demodule(i,1) = - 4;
        msg_demodule(i,2) = + 0.25;
        msg_demodule(i,3) = + 2;
    elseif( msg_data_temp(i)<0 && 3575<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<4022 )
        msg_demodule(i,1) = - 4;   
        msg_demodule(i,2) = - 0.25;
        msg_demodule(i,3) = + 2;
    elseif( msg_data_temp(i)<0 && 4022<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<4916 )
        msg_demodule(i,1) = - 5;  
        msg_demodule(i,2) = - 1;
        msg_demodule(i,3) = + 1;
    elseif( msg_data_temp(i)<0 && 4916<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<5363 )
        msg_demodule(i,1) = - 6;     
        msg_demodule(i,2) = - 2;
        msg_demodule(i,3) = + 0.25;
    elseif( msg_data_temp(i)<0 && 5363<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<5810 )
        msg_demodule(i,1) = - 6;     
        msg_demodule(i,2) = - 2;
        msg_demodule(i,3) = - 0.25;
    elseif( msg_data_temp(i)<0 && 5810<=abs(msg_data_temp(i)) && abs(msg_data_temp(i))<6704 )
        msg_demodule(i,1) = - 7;             
        msg_demodule(i,2) = - 3;
        msg_demodule(i,3) = - 1;
    elseif( msg_data_temp(i)<0 && 6704<=abs(msg_data_temp(i)) )
        msg_demodule(i,1) = - 7;        
        msg_demodule(i,2) = - 4;
        msg_demodule(i,3) = - 2;
    end       
end

Msg_Out = zeros(1,(module_mode+1)*data_length/2);

switch module_mode
    case 0
        Msg_Out = msg_data;
    case 1
        for i = 1 : data_length
            Msg_Out(i) = msg_demodule(i,1);
        end            
    case 2
        for i = 1 : data_length
            Msg_Out(2*i-1) = msg_demodule(i,1);
            Msg_Out( 2*i ) = msg_demodule(i,2);
        end      
    case 3
        for i = 1 : data_length
            Msg_Out(3*i-2) = msg_demodule(i,1);
            Msg_Out(3*i-1) = msg_demodule(i,2);                
            Msg_Out( 3*i ) = msg_demodule(i,3);
        end    
end
end