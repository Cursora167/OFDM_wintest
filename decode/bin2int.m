function [data_int] = bin2int(data_bin)
    data_int = data_bin(1)*32+data_bin(2)*16+data_bin(3)*8+ ...
               data_bin(4)*4+data_bin(5)*2+data_bin(6);
end