function [H0] = FR(I,c,alfa)
%FR 
%   Beräknar teststorheten Z (mha X) och jämför med standard normal på
%   konfidensgrad alfa

X = sum(I);
T = length(I);
p = 1-c;

Z = (X - T*p)./sqrt(T*p.*(1-p));
H0 = abs(Z).*ones(2,2) - norminv(1 - 0.5*alfa'.*ones(2,2));
end

