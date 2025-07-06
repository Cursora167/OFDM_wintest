function [data_bin] = int2bin(data_int) %将整数转化为6比特二进制数（CC译码器使用）
    data_bin = zeros(6,1);
    data_bin(1) = floor(data_int/32);
    data_int = data_int - data_bin(1)*32;
    data_bin(2) = floor(data_int/16);
    data_int = data_int - data_bin(2)*16;
    data_bin(3) = floor(data_int/8);
    data_int = data_int - data_bin(3)*8;
    data_bin(4) = floor(data_int/4);
    data_int = data_int - data_bin(4)*4;
    data_bin(5) = floor(data_int/2);    
    data_bin(6) = data_int - data_bin(5)*2;
end