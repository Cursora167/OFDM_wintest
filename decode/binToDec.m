function [b]=binToDec(a) %将任意二进制转化为十进制
    m=length(a);
    b=0;
    for i=1:m
        b=b+a(i)*2^(i-1);
    end
end