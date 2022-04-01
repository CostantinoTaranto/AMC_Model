%% Finite precision constructor
% This script computes the constructed candidates (with finite precision) for each of the examples
% that are present in file "construction_exapmles-inventory.xlsx" and
% writes down the results in a file

clear all

data_r=readtable("construction_examples-inventory.xlsx")

for curEx=1:numel(data_r.ExampleNum)

    y=data_r.y(curEx);
    w=data_r.w(curEx);

    % Neighboring blocks motion vector
    %Group 0
    mv0_h(1)=data_r.mv0_h_1(curEx);  %A2 x componentt
    mv0_v(1)=data_r.mv0_v_1(curEx);  %A2 y component
    mv0_h(2)=data_r.mv0_h_2(curEx);  %B2 x component
    mv0_v(2)=data_r.mv0_v_2(curEx);  %B2 y component
    mv0_h(3)=data_r.mv0_h_3(curEx);  %B3 x component
    mv0_v(3)=data_r.mv0_v_3(curEx);  %B3 y component
    %Group 1
    mv1_h(1)=data_r.mv1_h_1(curEx);  %B1 x component
    mv1_v(1)=data_r.mv1_v_1(curEx);  %B1 y component
    mv1_h(2)=data_r.mv1_h_2(curEx);  %B0 x component
    mv1_v(2)=data_r.mv1_v_2(curEx);  %B0 y component
    %Group 2
    mv2_h(1)=data_r.mv2_h_1(curEx);  %A1 x component
    mv2_v(1)=data_r.mv2_v_1(curEx);  %A1 y component
    mv2_h(2)=data_r.mv2_h_2(curEx);  %A0 x component
    mv2_v(2)=data_r.mv2_v_2(curEx);  %A0 y component;

    %Minimun distotion value
    D_min_hw=2^(28)-1;
    
    %Rows C(1) and C(2) contain the first and second best candidates respectively
    %The third column contains the third vector for which the distortion D is the
    %minimun one
    C_hw=zeros(1,3);
    
    % Best candiadate search
    for i=1:length(mv0_h)
        for j=1:length(mv1_h)
            %Calcolo qui MVS2' perché nel prossimo step, con gli MVS2
            %calcoleremo solo le distortion
            mv2p_h(i,j)= fix(-y*(mv1_v(j)-mv0_v(i))/w) + mv0_h(i);
            mv2p_v(i,j)= fix(+y*(mv1_h(j)-mv0_h(i))/w) + mv0_v(i);
            for k=1:length(mv2_h)
                if (mv0_h(i)~=-1024 && mv1_h(j)~=-1024 && mv2_h(k)~=-1024)
                    D(i,j,k)=(mv2p_v(i,j)-mv2_v(k))^2+(mv2p_h(i,j)-mv2_h(k))^2;
                else
                    D(i,j,k)=2^(28)-1;
                end
                if D(i,j,k)<D_min_hw
                    %Set the best candidate couple as the current one,
                    %the previous best couple becomes the second one
                    D_min_hw=D(i,j,k);
                    C_hw(1,1)=i; 
                    C_hw(1,2)=j;
                    C_hw(1,3)=k;
                end
            end
        end
    end

    data_w_struct(curEx).ExampleNum=data_r.ExampleNum(curEx);
    data_w_struct(curEx).y=y;
    data_w_struct(curEx).w=w;
    data_w_struct(curEx).mv0_h=mv0_h;
    data_w_struct(curEx).mv0_v=mv0_v;
    data_w_struct(curEx).mv1_h=mv1_h;
    data_w_struct(curEx).mv1_v=mv1_v;
    data_w_struct(curEx).mv2_h=mv2_h;
    data_w_struct(curEx).mv2_v=mv2_v;
    data_w_struct(curEx).mv2p_h=mv2p_h;
    data_w_struct(curEx).mv2p_v=mv2p_v;
    data_w_struct(curEx).D=D;
    data_w_struct(curEx).D_min_hw=D_min_hw;
    data_w_struct(curEx).C_hw=C_hw;

end

fprintf("Scansione terminata, sono stati scansionati %d esempi.\n",numel(data_r.ExampleNum));
data_w=struct2table(data_w_struct);
writetable(data_w,"construction_examples-hardware.xlsx");