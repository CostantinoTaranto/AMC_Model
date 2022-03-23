function quot = fxp(num,frac)
%Represent a number on X.frac bits
%   This function cuts out (rounding method: truncation) the factional part such that it can
%   be represented on X.frac bits. The number "num" must be considered
%   as a 2'sC number

signif_quot=fix(num*2^(frac)); %Takes only the significative part
quot_bin=dec2bin(signif_quot);

msb_weight=strlength(quot_bin)-frac-1;
quot=0;
i=1;%1: MSB
for cur_weight=msb_weight:(-1):(-frac)
    if num<0
        if cur_weight==msb_weight
            quot=quot-(2^cur_weight)*str2double(quot_bin(i));
        else
            quot=quot+(2^cur_weight)*str2double(quot_bin(i));
        end
    else
        quot=quot+(2^cur_weight)*str2double(quot_bin(i));
    end
    i=i+1;
end

