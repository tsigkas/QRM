function [c,ceq] = GEV_con(par, Tail)
%GEV_CON 
%   Bivillkoren för GEV. minustecken då villkoret är >

c = -1*(1+par(1)*Tail/par(2));
ceq = [];
end

