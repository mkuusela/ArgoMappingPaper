function r = normalPlusTQuantile(sigmaN,sigmaT,nu,prob)

nSample = 1000;

sample = zeros(nSample,1);

for i=1:nSample
    sample(i) = sigmaN * randn + sigmaT * trnd(nu);
end

r = quantile(sample,prob);