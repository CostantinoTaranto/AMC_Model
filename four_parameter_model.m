%% Four-parameter model
% This script computes the motion vectors for a point in a frame, given two
% motion vectors as reference

%Example-specific parameters

h=32;   %Current block height 
w=32;   %Current block width

%We are computing the third element in a triplet, the
%MV'S2 described in paper (2), which imposes that x=0 while y=h
x=0;
y=h;

mv0_h=84;   %MV0 x component
mv0_v=4;    %MV0 y component

mv1_h=88;   %MV1 x component
mv1_v=16;   %MV1 y component

%Result
mv_h=x*(mv1_h-mv0_h)/w - y*(mv1_v-mv0_v)/w + mv0_h
mv_v=x*(mv1_v-mv0_v)/w + y*(mv1_h-mv0_h)/w + mv0_v
