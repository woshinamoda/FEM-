%数据结构 BB AA（2bytes） + 3data x 5T（15bytes） +  leadofff(1byte)  +   包序号(1byte)
clear
clc
delete(instrfindall);
scom = 'COM26'; 
b = serial(scom);
b.InputBufferSize=2500;
Baudrate = 921600; 
set(b,'BaudRate',Baudrate);     
fopen(b);      
fwrite(b,[01]);    %%%发送0x01指令，开启数据读取
pause(1)

ECG_channel = 1;                        %通道数
ecg_cnt_max = ECG_channel*3*5;          %包字节数
ECG_bytes = zeros(1,ecg_cnt_max);       %定义一行存储

ecg_cnt_state = 0;                      %读取状态
ecg_cnt_count = 0;                      %读取数量
ecg_idx = 1;                            %包序号自动加1

ECG_frame = zeros(ECG_channel, 9);      
result_ecg = zeros(ECG_channel,2502);
result_ecg_idx = 1;

%%%搭建绘图框
fig=figure();
hold on;

line_ECG{1} = plot((1:size(result_ecg,2))/500, result_ecg(1,:));
ylabel('采集ECG电压值(uV)');
xlim([0,size(result_ecg,2)/500])                           
xlabel('ECG采集时间(s)');                                            

drawnow();

while true %while(1)
%%%变量功能注释     
%ecg_cnt_state（读取数组状态） 0：查找BB  1：查找AA  2：开始保存数据  3：查看校验位  4：包序号自动+1
%ecg_cnt_count（数组数量）
%ecg_sumchkm（ECG心电数量总和）

    [buff,count]=fread(b,1000,'uint8');  
    for index = 1:length(buff)
        switch(ecg_cnt_state)
            case 0
                if(buff(index) == 187) %0xBB
                    ecg_cnt_state = 1;
                else
                    ecg_cnt_state = 0;
                end
            case 1
                if(buff(index) == 170) %0xAA
                    ecg_cnt_state = 2;
                    ecg_cnt_count = 1;
                    ecg_sumchkm = 0;
                elseif(buff(index) == 187)  %%%读取到BB BB AA需要摘除BB项判断
                    ecg_cnt_state = 1;
                else 
                    ecg_cnt_state = 0;
                end
            case 2
                ECG_bytes(1, ecg_cnt_count) = buff(index);
                ecg_cnt_count = ecg_cnt_count + 1;
                ecg_sumchkm = ecg_sumchkm + buff(index);
                if(ecg_cnt_count == ecg_cnt_max + 1)    %%%读够包数据
                    ecg_cnt_state = 3;
                else
                    ecg_cnt_state = 2;
                end
            case 3
                if(buff(index) == 0)    %%%读取到校验位是0
                    ecg_cnt_state = 4;
                else
                    ecg_cnt_state = 0;  %%%校验错误，这一包直接丢掉
                end
            case 4
                ECG_Sequence(ecg_idx,1) = buff(index);      %%% 自动+1数据传递到矩阵ECG_Sequence中
%%%        C语言代码如下
%%%        判断boardChannelDataInt[i] == 0x00800000
%%%        YES : boardChannelDataInt[i] |= 0xFF000000
%%%        NO  ：boardChannelDataInt[i] &= 0x00FFFFFF
                for i=1:5 %一包数据5个点
                    if(ECG_bytes(1,i*3-2)>127)   %%%第一个字节大于0xff
                        ECG_frame(1,i) = swapbytes(typecast(uint8([255 ECG_bytes((i*3-2):i*3)]),'int32'));
                    else
                        ECG_frame(1,i) = swapbytes(typecast(uint8([0 ECG_bytes((i*3-2):i*3)]),'int32'));          
                    end
                end
                
                

                
                
                
                
                
                
                
                
                
                
                
                
        end     
    end
end











































