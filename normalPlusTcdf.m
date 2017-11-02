function r = normalPlusTcdf(sigmaN,sigmaT,nu,x)

nSample = 10000;

sample = zeros(nSample,1);

% Sample using the knowledge that the distribution is symmetric
for i=1:nSample
    sample(i) = abs(sigmaN * randn + sigmaT * trnd(nu));
end
sample = [sample; -sample];
nSample = 2*nSample;

rTemp = sum(sample < x)/nSample;
switch rTemp % Add jitter to remove the stripes
    case 1
        r = rTemp + unifrnd(-0.5*1/nSample,0); 
    case 0
        r = rTemp + unifrnd(0,0.5*1/nSample);
    otherwise
        r = rTemp + unifrnd(-0.5*1/nSample,0.5*1/nSample);
end
