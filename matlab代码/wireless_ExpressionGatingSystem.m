%���ݽṹ BB AA��2bytes�� + 3data x 5T��15bytes�� +  leadofff(1byte)  +   �����(1byte)
clear
clc
delete(instrfindall);
scom = 'COM26'; 
b = serial(scom);
b.InputBufferSize=2500;
Baudrate = 921600; 
set(b,'BaudRate',Baudrate);     
fopen(b);      
fwrite(b,[01]);    %%%����0x01ָ��������ݶ�ȡ
pause(1)

ECG_channel = 1;                        %ͨ����
ecg_cnt_max = ECG_channel*3*5;          %���ֽ���
ECG_bytes = zeros(1,ecg_cnt_max);       %����һ�д洢

ecg_cnt_state = 0;                      %��ȡ״̬
ecg_cnt_count = 0;                      %��ȡ����
ecg_idx = 1;                            %������Զ���1

ECG_frame = zeros(ECG_channel, 9);      
result_ecg = zeros(ECG_channel,2502);
result_ecg_idx = 1;

%%%���ͼ��
fig=figure();
hold on;

line_ECG{1} = plot((1:size(result_ecg,2))/500, result_ecg(1,:));
ylabel('�ɼ�ECG��ѹֵ(uV)');
xlim([0,size(result_ecg,2)/500])                           
xlabel('ECG�ɼ�ʱ��(s)');                                            

drawnow();

while true %while(1)
%%%��������ע��     
%ecg_cnt_state����ȡ����״̬�� 0������BB  1������AA  2����ʼ��������  3���鿴У��λ  4��������Զ�+1
%ecg_cnt_count������������
%ecg_sumchkm��ECG�ĵ������ܺͣ�

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
                elseif(buff(index) == 187)  %%%��ȡ��BB BB AA��Ҫժ��BB���ж�
                    ecg_cnt_state = 1;
                else 
                    ecg_cnt_state = 0;
                end
            case 2
                ECG_bytes(1, ecg_cnt_count) = buff(index);
                ecg_cnt_count = ecg_cnt_count + 1;
                ecg_sumchkm = ecg_sumchkm + buff(index);
                if(ecg_cnt_count == ecg_cnt_max + 1)    %%%����������
                    ecg_cnt_state = 3;
                else
                    ecg_cnt_state = 2;
                end
            case 3
                if(buff(index) == 0)    %%%��ȡ��У��λ��0
                    ecg_cnt_state = 4;
                else
                    ecg_cnt_state = 0;  %%%У�������һ��ֱ�Ӷ���
                end
            case 4
                ECG_Sequence(ecg_idx,1) = buff(index);      %%% �Զ�+1���ݴ��ݵ�����ECG_Sequence��
%%%        C���Դ�������
%%%        �ж�boardChannelDataInt[i] == 0x00800000
%%%        YES : boardChannelDataInt[i] |= 0xFF000000
%%%        NO  ��boardChannelDataInt[i] &= 0x00FFFFFF
                for i=1:5 %һ������5����
                    if(ECG_bytes(1,i*3-2)>127)   %%%��һ���ֽڴ���0xff
                        ECG_frame(1,i) = swapbytes(typecast(uint8([255 ECG_bytes((i*3-2):i*3)]),'int32'));
                    else
                        ECG_frame(1,i) = swapbytes(typecast(uint8([0 ECG_bytes((i*3-2):i*3)]),'int32'));          
                    end
                end
                
                

                
                
                
                
                
                
                
                
                
                
                
                
        end     
    end
end











































