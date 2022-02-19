%% candidate_search_4par
% This script selects the best candidate(s) for the affine AMVP prediction

clear

%Example-specific parameters

h=16;   %Current block height 
w=16;   %Current block width

%We are computing the third element in a triplet, the
%MV'S2 described in paper (2), which imposes that x=0 while y=h
x=0;
y=h;

% Neighboring blocks motion vectors
%Group 0
mv0_h(1)=1;   %A2 x component
mv0_v(1)=9;    %A2 y component

mv0_h(2)=1;   %B2 x component
mv0_v(2)=9;    %B2 y component

mv0_h(3)=14;   %B3 x component
mv0_v(3)=-15;    %B3 y component

%Group 1
mv1_h(1)=-11;   %B1 x component
mv1_v(1)=-11;   %B1 y component

mv1_h(2)=-12;   %B0 x component
mv1_v(2)=-11;    %B0 y component

%Group 2
mv2_h(1)=1;   %A1 x component
mv2_v(1)=9;    %A1 y component

mv2_h(2)=1;   %A0 x component
mv2_v(2)=9;  %A0 y component

D_min=121237;
D_min2=121238;

%C(1) and C(2) contain the first and second best candidates respectively
C=zeros(2,2);

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
                C(1,1)=i; 
                C(1,2)=j;
            elseif D<D_min2
                D_min2=D;
                C(2,1)=i; %Second best candidates
                C(2,2)=j;
            end
        end
    end
end

% Nota: In questo script la coppia 1,1 compare due volte in quanto
% mv_A1=mv_A0 e quindi per due volte la distorsione calcolata corrisponde
% alla minima




