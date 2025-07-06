function msg_Out = data_read(read_mode,file1,file2)
%读取数据文件，按有符号数读出；
    if(read_mode ==0)
    %% CSV文件
        % 表头名称
        table_head1 = 'Frame_Detection_InRe1[11:0]';
        table_head2 = 'Frame_Detection_InIm1[11:0]';

        excel_data = readtable(file1,"TextType","string",...
                    "VariableNamingRule","preserve");
        data_re = excel_data{1:8:end,table_head1};
        data_im = excel_data{1:8:end,table_head2};
        msg_Out = (data_re + 1i*data_im).';
    else
    %% TXT文件
        % %16位位宽
        % data_re = cast(typecast(uint16(load(file1)),'int16'),'double');
        % data_im = cast(typecast(uint16(load(file2)),'int16'),'double');
        % msg_Out = (data_re + 1i*data_im).';


        % 其它位宽,无符号转有符号数
        bit_width = 12;                                                    %位宽设置

        data_re_temp = load(file1);
        data_im_temp = load(file2);
        data_un = [data_re_temp,data_im_temp];
        data_sn = arrayfun(@(x) bitget(x,bit_width)*(x - 2^bit_width)...
                   + ~bitget(x, bit_width) * x, data_un);
        msg_Out = (data_sn(:,1) + 1i*data_sn(:,2)).';

    end
end