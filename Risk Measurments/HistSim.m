function [VaR] = HistSim(R,win, c, vol)
%HISTSIM 
%   Beräknar var från historiska simuleringar
%   Om vol skickas in körs justering enligt Hull & White
%   Annars körs "standard" historisk simulering

if ~exist("vol","var")
    vol = ones(size(R));
end

start = win + 2; % första perioden för att estimera VaR

VaR = zeros(length(R)-win,length(c));
Rnorm = R./vol;
for i = 1:length(VaR)
	VaR(i,:) = -vol(i+win)*prctile(Rnorm(i:(i+win-1)), 100*(1-c));
end

end