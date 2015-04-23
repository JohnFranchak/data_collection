function [finished] = plotpsych(min, max, mu, sigma, succtrials, totaltrials, units, symbol,color,id)
x = min:.01:max;
affmu = mu;
affsig = sigma;
affrate = succtrials ./ totaltrials;
afftrials = totaltrials;

afx = normcdf(x,affmu, affsig);

plot(x, afx,color,'LineWidth',2);
axis([min max -.01 1.01])
hold on
for i = 1:length(units)
    if not(isnan(affrate(i)))
        markersize = (afftrials(i) * 2) + 5;
        h = plot(units(i),affrate(i),symbol,'LineWidth',2,'MarkerSize',markersize);
        title(sprintf('%s, mu: %3.1f, sig: %3.1f', id(5:end-4), mu, sigma));
    end
end
hold off

finished = 1;