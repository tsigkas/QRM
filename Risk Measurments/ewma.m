function vol = ewma(lamda, r, init)
vol = zeros(size(r));

vol(1) = init;
for i = 2:length(vol)
    vol(i) = lamda*vol(i-1) + (1-lamda)*r(i-1)^2;
end

vol = sqrt(vol);
vol = vol(2:end);

end