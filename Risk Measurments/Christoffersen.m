function [H0] = Christoffersen(I, alfa)
%CHRISTOFFERSEN 
%   Genererar elementen n och ML-skattningarna av pi med dessa
%   Beräknar sedan teststorheten och jämför med chi2(1) på konfidensgrad
%   alfa

% 2st 2x2 matriser (95 & 99% VaR)
N = zeros(2,2,2);

for i = 1:(length(I)-1)
    N(I(i,1)+1, I(i+1,1)+1,1) = N(I(i,1)+1, I(i+1,1)+1,1) +1;
    N(I(i,2)+1, I(i+1,2)+1,2) = N(I(i,2)+1, I(i+1,2)+1,2) +1;
end

X = sum(I);
T = length(I);

pi = X/(T-1);
Pi = N./sum(N,2);

L0 = (1-pi).^(T-1-X).*(pi).^(X);
L1 = Pi(1,1,:).^(N(1,1,:)).*Pi(1,2,:).^(N(1,2,:)).*Pi(2,1,:).^(N(2,1,:)).*Pi(2,2,:).^(N(2,2,:));
L1 = squeeze(L1)';

test = -2*log(L0./L1);
H0 = test.*ones(2,2) - chi2inv(1-alfa'.*ones(2,2),1);

end

