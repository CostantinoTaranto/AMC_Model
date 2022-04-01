%% candidate_search
% This script selects the best candidate(s) for the affine AMVP prediction
% Nota: Per questo algoritmo non cambia nulla se utilizzare un modello a 4
% o a 6 parametri perché il procedimento è lo stesso

clear

%Example-specific parameters

h=32;   %Current block height 
w=16;   %Current block width

%We are computing the third element in a triplet, the
%MV'S2 described in paper (2), which imposes that x=0 while y=h
x=0;
y=h;

% Neighboring blocks motion vectors
%Group 0
mv0_h(1)=28;   %A2 x component
mv0_v(1)=4;    %A2 y component

mv0_h(2)=28;  %B2 x component
mv0_v(2)=4;     %B2 y component

mv0_h(3)=40;   %B3 x component
mv0_v(3)=-6;    %B3 y component

%Group 1
mv1_h(1)=40;   %B1 x component
mv1_v(1)=-6;   %B1 y component

mv1_h(2)=34;   %B0 x component
mv1_v(2)=-8;    %B0 y component

%Group 2
mv2_h(1)=28;   %A1 x component
mv2_v(1)=4;     %A1 y component

mv2_h(2)=15;   %A0 x component
mv2_v(2)=-9;  %A0 y component

D_min=121237;
D_min2=121238;

%Rows C(1) and C(2) contain the first and second best candidates respectively
%The third row contains the third vector for which the distortion D is the
%minimun one
C=zeros(2,3);

% Best candiadate search
for i=1:length(mv0_h)
    for j=1:length(mv1_h)
        %Calcolo qui MVS2' perché nel prossimo step, con gli MVS2
        %calcoleremo solo le distortion
        mv2p_h=x*(mv1_h(j)-mv0_h(i))/w - y*(mv1_v(j)-mv0_v(i))/w + mv0_h(i);
        mv2p_v=x*(mv1_v(j)-mv0_v(i))/w + y*(mv1_h(j)-mv0_h(i))/w + mv0_v(i);
        for k=1:length(mv2_h)
            D=sqrt((mv2p_v-mv2_v(k))^2+(mv2p_h-mv2_h(k))^2);
            if D<D_min
                %Set the best candidate couple as the current one,
                %the previous best couple becomes the second one
                D_min2=D_min;
                D_min=D;
                C(2,1)=C(1,1);
                C(2,2)=C(1,2);
                C(2,3)=C(1,3);
                C(1,1)=i; 
                C(1,2)=j;
                C(1,3)=k;
            elseif D<D_min2
                %Check if this candidate couple is not the same as the best one
                if mv0_h(i)~=mv0_h(C(1,1)) || mv0_v(i)~=mv0_v(C(1,1)) || mv1_h(j)~=mv1_h(C(1,2)) || mv1_v(j)~=mv1_v(C(1,2))
                    %If they're not the same, you can update the second
                    %best candidate
                    D_min2=D;
                    C(2,1)=i; %Second best candidates
                    C(2,2)=j;
                    C(2,3)=k;
                end
            end
        end
    end
end



