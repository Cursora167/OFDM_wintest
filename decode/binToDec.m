function [b]=binToDec(a) %�����������ת��Ϊʮ����
    m=length(a);
    b=0;
    for i=1:m
        b=b+a(i)*2^(i-1);
    end
end