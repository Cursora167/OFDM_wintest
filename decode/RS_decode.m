function [output] = RS_decode(input,codeRate) %RS译码器，第二维参数表示译码后的长度

    RS_button = 0; % 设置RS译码总开关，0则为关闭，直接取数据位；1则会进行RS译码。

    % 码长信息
    inputL = length(input); % 编码后码长
    infoL = inputL*codeRate; % 编码前码长
    
    % Basic parameteRS for RS Coding
    a_0_255 = zeros(8,256);
    a_0_255(:,1)=[1;0;0;0;0;0;0;0];
    a_0_255(:,2)=[0;1;0;0;0;0;0;0];
    for i=3:255
        a_0_255(:,i)=RS_multiplier(a_0_255(:,2),a_0_255(:,i-1));
    end
    a_0_255_de = a_0_255(1,:)+a_0_255(2,:)*2+a_0_255(3,:)*4+a_0_255(4,:)*8+ ...
                 a_0_255(5,:)*16+a_0_255(6,:)*32+a_0_255(7,:)*64+a_0_255(8,:)*128;
             
    RS_m = 8; % Number of bits per symbol in each codeword
    RS_t = 8; % Error-correction capability
    shortLength = 0; % 编码缩短长度
    % 译码长度
    RS_n = 2^RS_m-1-shortLength; RS_k = RS_n-2*RS_t; % Message length and codeword length
    
    %查看是否需要补0，补到RS_n*8，补信息位的0，再补校验位的0；如果校验位数超过最大的16*8，则删去在编码时加的多余补零
    if((rem(length(input),RS_n*8)>0) && ((inputL-infoL)<=(16*8)))
        RS_decodingIn=[input(1:infoL) ; zeros(RS_k*RS_m-infoL,1) ; input(infoL+1:inputL) ; zeros(16*RS_t+infoL-inputL,1)];
    elseif((rem(length(input),RS_n*8)>0) && ((inputL-infoL)>(16*8)))
        RS_decodingIn=[input(1:infoL) ; zeros(RS_k*RS_m-infoL,1) ; input(infoL+1:infoL+128)];
    elseif((rem(length(input),RS_n*8)>0) && (inputL>(255*8)))
        RS_decodingIn = input(1:2040);
    else
        RS_decodingIn = input;
    end

    %RS decode own
    rec_reshape = (reshape(RS_decodingIn,RS_m,RS_n))';
    %伴随式计算
    synd = zeros(8,2*RS_t);
    a_1_8 = zeros(8,8);
    a_1_8(:,1) = [0;1;0;0;0;0;0;0];
    for i = 2:2*RS_t
        a_1_8(:,i) = RS_multiplier(a_1_8(:,i-1),a_1_8(:,1));
    end
    for i = 1:RS_n
       for j =1:2*RS_t
           synd(:,j)=RS_adder(RS_multiplier(a_1_8(:,j),synd(:,j)),rec_reshape(i,:)');
       end
    end
    %求解关键方程
    %初始化
    lambda = zeros(8,RS_t+1);
    b = zeros(8,RS_t+1);
    lambda(:,1) = [1; 0; 0; 0; 0; 0; 0; 0];
    b(:,1) = [1; 0; 0; 0; 0; 0; 0; 0];
    k = 0;
    gamma=[1; 0; 0; 0; 0; 0; 0; 0];
    delta = synd;
    theta = synd;

    lambda_new = zeros(8,RS_t+1); 
    delta_new = zeros(8,RS_t*2);  
    %迭代求解
    for r=1:2*RS_t
        lambda_new(:,1)=RS_multiplier(gamma,lambda(:,1));
        for i=2:RS_t+1
            lambda_new(:,i)=RS_adder(RS_multiplier(gamma,lambda(:,i)), RS_multiplier(delta(:,1),b(:,i-1)));
        end
        for i=1:RS_t*2-1
            delta_new(:,i)=RS_adder(RS_multiplier(gamma,delta(:,i+1)),RS_multiplier(delta(:,1),theta(:,i)));
        end
        delta_new(:,RS_t*2)=RS_multiplier(delta(:,1),theta(:,RS_t*2));

       if(sum(delta(:,1) ~= 0)~= 0 && k>=0)   
           b=lambda;
           theta=[delta(:,2:RS_t*2),zeros(8,1)];
           gamma=delta(:,1);
           k=-k-1;
       else
           b = [zeros(8,1),b(:,1:RS_t)];
           k=k+1;
       end
       lambda = lambda_new;
       delta = delta_new;
    end
    err_position = lambda;
    err_position_0_inv = a_0_255(:,mod(256-find(a_0_255_de==binToDec(err_position(:,1))),255)+1);
    err_position_org=zeros(8,RS_t+1);
    for i=1:RS_t+1
        err_position_org(:,i) = RS_multiplier(err_position(:,i),err_position_0_inv);
    end
    err_position = err_position_org;
    %钱氏搜索
    index = 1;
    position = [-1];
    for i=1:255
        err_position(:,2) = RS_multiplier(err_position(:,2),a_1_8(:,1));
        err_position(:,3) = RS_multiplier(err_position(:,3),a_1_8(:,2));
        err_position(:,4) = RS_multiplier(err_position(:,4),a_1_8(:,3));
        err_position(:,5) = RS_multiplier(err_position(:,5),a_1_8(:,4));
        error = err_position(:,1);
        for j=2:RS_t+1
            error = RS_adder(error,err_position(:,j));
        end
        if(sum(error ~= 0)== 0)
            position(index) = (i-shortLength);
            index = index+1;
        end
    end
    if(isempty(find(position<=0)))
        %错误值更正
        err_position = err_position_org;
        err_pattern = zeros(8,index-1);
        err_value = synd(:,1:RS_t);
        for i=2:RS_t
            for r=1:i-1
                err_value(:,i)=RS_adder(err_value(:,i),RS_multiplier(synd(:,i-r),err_position(:,r+1)));
            end
        end

        for i=1:index-1
            gf_error_pos = a_0_255(:,RS_n-position(i)+1);
            gf_error_pos_inv = a_0_255(:,mod(256-find(a_0_255_de==binToDec(gf_error_pos)),255)+1);
            error_pos_value = RS_adder(err_position(:,2),RS_multiplier(err_position(:,4),RS_multiplier(gf_error_pos_inv,gf_error_pos_inv)));
            error_pos_value_inv = a_0_255(:,mod(256-find(a_0_255_de==binToDec(error_pos_value)),255)+1);

            err_value_current = err_value(:,1);
            for j=2:RS_t
                err_value_ite = err_value(:,j);
                for t = 1:j-1;
                    err_value_ite = RS_multiplier(gf_error_pos_inv,err_value_ite);
                end
                err_value_current = RS_adder(err_value_current,err_value_ite);
            end
            err_pattern(:,i) = RS_multiplier(err_value_current,error_pos_value_inv);
        end
        % 错误纠正
        rec_reshape_modify = rec_reshape;
        for i=1:length(position)
            rec_reshape_modify(position(i),:) = RS_adder(rec_reshape_modify(position(i),:),err_pattern(:,i)');
        end
        RS_decode_result_tmp = (reshape(rec_reshape_modify',RS_m*RS_n,1));
        RS_decode_result = RS_decode_result_tmp(1:RS_m*RS_k,1);
    else
        RS_decode_result_tmp = (reshape(rec_reshape',RS_m*RS_n,1));
        RS_decode_result = RS_decode_result_tmp(1:RS_m*RS_k,1);
    end
    
    % 取RS译码后前infoL位(信息位位数)
    if(RS_button==0)
        output = input(1:infoL,1);
    elseif(RS_button==1)
        output = RS_decode_result(1:infoL,1);
    end
    
end