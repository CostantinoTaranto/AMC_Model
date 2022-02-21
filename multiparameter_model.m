%% Multi-parameter model
% This script computes the motion vectors for a point in a frame, given the
% control point motion vectors. A flag indicates whether the 4 or the 6
% parameter model is used

%Example-specific parameters

h=32;       %Current block height 
w=32;       %Current block width
sixPar=0;   %If 0, the the 4 parameter model is used

%If we are using the 4 parameter model, we compute the bottom-left block
%MV, otherwise we calculate the bottom-right one
x=0;
y=h;
if sixPar==1
    x=h;
end

mv0_h=84;   %MV0 x component
mv0_v=4;    %MV0 y component

mv1_h=88;   %MV1 x component
mv1_v=16;   %MV1 y component

%if we're using the sixPar model, we input also the MV2
if sixPar==1
    mv2_h=80;
    mv2_v=21;
end


%Result
a_h=(mv1_h-mv0_h)/w;
a_v=(mv1_v-mv0_v)/w;
if sixPar==0
    b_h=-(mv1_v-mv0_v)/w;
    b_v=+(mv1_h-mv0_h)/w;
else
    b_h=+(mv2_h-mv0_h)/h;
    b_v=+(mv2_v-mv0_v)/h;
end

sixPar
mv_h=x*a_h + y*b_h + mv0_h
mv_v=x*a_v + y*b_v + mv0_v
