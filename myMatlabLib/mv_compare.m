function [abs_mv_ratio,phase_mv_diff] = mv_compare(mv_h,mv_v)

%This function return the ratio of the absolute values and the phase
%difference between the first and second element (in radians)

abs_mv=zeros(2,1);
phase_mv=zeros(2,1);

for i=1:2
    abs_mv(i)=sqrt(mv_h(i)^2+mv_v(i)^2);
    phase_mv(i)=atan(mv_v(i)/mv_h(i));
end

abs_mv_ratio=abs_mv(1)/abs_mv(2);
phase_mv_diff=phase_mv(1)-phase_mv(2);
