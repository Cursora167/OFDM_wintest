function data_num =  data_num_cal(symbol_num,sub_data_num,code_mode,module_mode)
%根据参数计算每帧数据量；

switch code_mode
    case 0
        code_factor = 1;
    case 1
        code_factor = 0.5;
    case 2
        code_factor = 0.75;
    otherwise
        disp('无对应编码方式');
end

switch module_mode
    case 0
        module_factor = 1;
    case 1
        module_factor = 2;
    case 2
        module_factor = 4;
    case 3
        module_factor = 6;
    otherwise
        disp('无对应调制方式');
end
num_factor = code_factor*module_factor;
data_num = symbol_num*sub_data_num*num_factor;
end