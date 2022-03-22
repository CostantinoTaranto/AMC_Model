%% runner.m
%This function runs a script of type "candidate_search_ex" and returns
%the input and output important values

function [mv0_h,mv0_v,mv1_h,mv1_v,mv2_h,mv2_v,y,w,C]=runner(exampleNum)

script=strcat("candidate_search_ex",num2str(exampleNum));

run(script)