function msg_module = tran_module(msg_encode,module_mode,symbol_num, ...
                                   FFT_num,pilot_Sub,pilot_sym,data_Sub)
%调制：0:无调制、1：QOSK、2：16QAM、3：64QAM；
%与Vivado相同，64QAM最好不要用1/2码率，会导致校验位的溢出而需要补零，影响性能

    % 根据不同调制方式编出符号以及功率因子
    switch module_mode
        case 0
            msg_encode_str = num2str(reshape(msg_encode,1,[])','%d');
            %power_factor = power(2,13);                            %功率因子      
            power_factor = 1;                                     
        case 1
            msg_encode_str = num2str(reshape(msg_encode,2,[])','%d');
            power_factor = power(2,13)/sqrt(2);
        case 2
            msg_encode_str = num2str(reshape(msg_encode,4,[])','%d');
            power_factor = power(2,13)/sqrt(10);
        case 3
            msg_encode_str = num2str(reshape(msg_encode,6,[])','%d');
            power_factor = power(2,13)/sqrt(42);
    end
    
    % 根据符号调制出不同符号及大小的实部虚部
    module_out_num = length(msg_encode_str);
    msg_module_pre = zeros(1,module_out_num);
    for index = 1:module_out_num
        switch module_mode
           case 0
                switch msg_encode_str(index,:)
                    case '0'
                        msg_module_pre(index) = 0;
                    case '1'
                        msg_module_pre(index) = 1;
                end
                
            case 1
                switch msg_encode_str(index,:)
                    case '00'
                        msg_module_pre(index) = + 1 + 1j;
                    case '01'
                        msg_module_pre(index) = + 1 - 1j;
                    case '10'
                        msg_module_pre(index) = - 1 + 1j;
                    case '11'
                        msg_module_pre(index) = - 1 - 1j;
                end
                
            case 2
                switch msg_encode_str(index,3:4) % 后2位作虚部判断
                    case '01'
                        msg_module_pre(index) = + 3j;
                    case '00'
                        msg_module_pre(index) = + 1j;
                    case '10'
                        msg_module_pre(index) = - 1j;
                    case '11'
                        msg_module_pre(index) = - 3j;
                end    
                switch msg_encode_str(index,1:2) % 前2位作实部判断
                    case '01'
                        msg_module_pre(index) = + 3 + msg_module_pre(index);
                    case '00'
                        msg_module_pre(index) = + 1 + msg_module_pre(index);
                    case '10'
                        msg_module_pre(index) = - 1 + msg_module_pre(index);
                    case '11'
                        msg_module_pre(index) = - 3 + msg_module_pre(index);
                end                       
            case 3
                switch msg_encode_str(index,4:6) % 后3位作虚部判断
                    case '011'
                        msg_module_pre(index) = + 7j;
                    case '010'
                        msg_module_pre(index) = + 5j;
                    case '000'
                        msg_module_pre(index) = + 3j;
                    case '001'
                        msg_module_pre(index) = + 1j;
                    case '101'
                        msg_module_pre(index) = - 1j;
                    case '100'
                        msg_module_pre(index) = - 3j;
                    case '110'
                        msg_module_pre(index) = - 5j;
                    case '111'
                        msg_module_pre(index) = - 7j;                        
                end    
                switch msg_encode_str(index,1:3) % 前3位作实部判断
                    case '011'
                        msg_module_pre(index) = + 7 + msg_module_pre(index);
                    case '010'
                        msg_module_pre(index) = + 5 + msg_module_pre(index);
                    case '000'
                        msg_module_pre(index) = + 3 + msg_module_pre(index);
                    case '001'
                        msg_module_pre(index) = + 1 + msg_module_pre(index);
                    case '101'
                        msg_module_pre(index) = - 1 + msg_module_pre(index);
                    case '100'
                        msg_module_pre(index) = - 3 + msg_module_pre(index);
                    case '110'
                        msg_module_pre(index) = - 5 + msg_module_pre(index);
                    case '111'
                        msg_module_pre(index) = - 7 + msg_module_pre(index);                                 
                end                  
        end
    end
    
    % 功率归一化，不同调制方式对应的功率不同
    msg_module_pre = (reshape(msg_module_pre,[],symbol_num)).'*power_factor;
    
    % 加上零子载波
    msg_module = zeros(symbol_num,FFT_num);
    msg_module(:,pilot_Sub) = pilot_sym*8192;
    msg_module(:,data_Sub) = msg_module_pre;

    msg_module = round(msg_module);

end