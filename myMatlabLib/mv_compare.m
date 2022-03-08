function [abs_mv_ratio,phase_mv_diff] = mv_compare(mv_h,mv_v)

%This function return the ratio of the absolute values and the phase
%difference between the first and second element (in deg)

abs_mv=zeros(2,1);
phase_mv=zeros(2,1);

for i=1:2
    abs_mv(i)=sqrt(mv_h(i)^2+mv_v(i)^2);
    phase_mv(i)=atan2(mv_v(i),mv_h(i));
    if phase_mv(i)<0 %Porto tutti gli angoli in valore positivo in modo da restituire valori di differenza di fase sensati
        phase_mv(i)=phase_mv(i)+2*pi;
    end
end

abs_mv_ratio=abs_mv(1)/abs_mv(2);
phase_mv_diff=abs((phase_mv(1)-phase_mv(2))*(180/pi));
%Se la differenza di fase è più di 180 gradi
%allora misuro "nell'altro verso"
if phase_mv_diff>180    
    phase_mv_diff=360-phase_mv_diff;
end
