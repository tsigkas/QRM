function plotVaR(VaR, time, uppg, c, r)
subplot(4,1,1:3)
plot(time, VaR*100);
    title(uppg + ") Portfölj-VaR (%)");
    legend("c = " + c(1)*100 + "%","c = " + c(2)*100 + "%", "Location", "northwest");
    ylabel("Relativa förluster");
subplot(4,1,4)
plot(time,r*100)
    ylabel("Avkastningar");

if exist("save","var") || save
    saveas(gcf, uppg, "epsc");
end
end
