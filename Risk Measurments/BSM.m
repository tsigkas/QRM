function [Price] = BSM(S,K,vol,r,T,q, type)
%BSM 
%   Pris för europeiska calls/puts enligt BSM

Price = zeros(size(type));
for i = 1:length(Price)
    Price(i) = blsprice(S,K(i),vol(i),r,T(i),q(i));
    if type(i) == "P"
        % PC-parity
        Price(i) = Price(i)+K(i)*exp(-r*T(i))-S*exp(-q(i)*T(i));
        
    end
end
end