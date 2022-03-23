%% candidate_search_comp_algorithm
% This script runs all of the previous scripts and compare the result with
% the approximated ones

clear all
clc

%Acquire the last example number
prompt = {'Enter the last example number:'};
dlgtitle = 'Example file limit';
dims = [5 100];
definput = {'29'};
inputdata = inputdlg(prompt,dlgtitle,dims,definput);

%Load example data
lastFileNum=str2num(cell2mat(inputdata));


for curFile=1:lastFileNum
    
    try
        [mv0_h,mv0_v,mv1_h,mv1_v,mv2_h,mv2_v,y,w,C]=runner(curFile);
        %With this code executed, now compare the results with
        %The approximated (hardware solution)
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
                mv2p_h= fix(-y*(mv1_v(j)-mv0_v(i))/w) + mv0_h(i);
                mv2p_v= fix(+y*(mv1_h(j)-mv0_h(i))/w) + mv0_v(i);
                for k=1:length(mv2_h)
                    D=(mv2p_v-mv2_v(k))^2+(mv2p_h-mv2_h(k))^2;
                    if D<D_min_hw
                        %Set the best candidate couple as the current one,
                        %the previous best couple becomes the second one
                        D_min_hw=D;
                        C_hw(1,1)=i; 
                        C_hw(1,2)=j;
                        C_hw(1,3)=k;
                    end
                end
            end
        end
        %Once you have obtained the two results, compare them. If mismatch,
        %exit
        if C_hw(1,:)==C(1,:)
            fprintf("Algorithm output match in example %d. C_hw=[%d,%d,%d]\tC=[%d,%d,%d]\n",curFile,C_hw(1,1),C_hw(1,2),C_hw(1,3),C(1,1),C(1,2),C(1,3));
        else
            fprintf("Algorithm output MISmatch in example %d!!! C_hw=[%d,%d,%d]\tC=[%d,%d,%d]\n",curFile,C_hw(1,1),C_hw(1,2),C_hw(1,3),C(1,1),C(1,2),C(1,3));
            return
        end

    catch
        fprintf("File number %d missing.\n",curFile);
    end
end