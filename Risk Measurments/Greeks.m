function [greeks] = Greeks(S,K,vol,r,T,q,type,greek_type)
%GREEKS 
%   partiella derivator enligt BSM

d1 = @(S,K,vol,r,T,q) (log(S/K) + (r-q+0.5*vol^2)*T)/(vol*sqrt(T));
d2 = @(S,K,vol,r,T,q) (d1(S,K,vol,r,T,q)-vol*sqrt(T));

delta_c = @(S,K,vol,r,T,q)  exp(-q*T)*normcdf( d1(S,K,vol,r,T,q));
delta_p = @(S,K,vol,r,T,q) -exp(-q*T)*normcdf(-d1(S,K,vol,r,T,q));

vega = @(S,K,vol,r,T,q) S*exp(-q*T)*normpdf(d1(S,K,vol,r,T,q))*sqrt(T);

rho_c = @(S,K,vol,r,T,q)  K*T*exp(-r*T)*normcdf( d2(S,K,vol,r,T,q));
rho_p = @(S,K,vol,r,T,q) -K*T*exp(-r*T)*normcdf(-d2(S,K,vol,r,T,q));

greeks = zeros(size(type));
for i = 1:length(greeks)
    if greek_type == "delta"
        if type(i) == "C"
            greeks(i)  =  delta_c(S,K(i),vol(i),r,T(i),q(i));
        else
            greeks(i) = delta_p(S,K(i),vol(i),r,T(i),q(i));
        end
    elseif greek_type == "vega"
        greeks(i) = vega(S,K(i),vol(i),r,T(i),q(i));
    else
        if type(i) == "C"
            greeks(i) = rho_c(S,K(i),vol(i),r,T(i),q(i));
        else
            greeks(i) = rho_p(S,K(i),vol(i),r,T(i),q(i));
        end
    end
end    

end