function val = negLogLikAnisotropy(params,interpLatAggr,interpLongAggr,interpResAggr)

theta1 = exp(params(1));
theta2 = exp(params(2));
sigma = exp(params(3));
a = exp(params(4));

disp([theta1,theta2,sigma,a]);

largeVal = 1e10;

if ~(theta1 < largeVal && theta2 < largeVal && sigma < largeVal && a < largeVal)
    val = NaN;
    disp(val);
    return;
end

if ~(theta1 > eps && theta2 > eps && sigma > eps && a > eps)
    val = NaN;
    disp(val);
    return;
end

nYear = size(interpResAggr,2);

val = 0;

for iYear = 1:nYear
    %disp(iYear);
    
    interpLatYear = interpLatAggr{iYear};
    interpLongYear = interpLongAggr{iYear};
    interpResYear = interpResAggr{iYear};
    
    nRes = length(interpResYear);
    %disp(nRes);
    
    covObs = zeros(nRes,nRes);
    
    %tic;
    for i = 1:nRes
        %disp(i);
        for j = 1:nRes
            covObs(i,j) = exponentialCovarianceAnisotropy(interpLatYear(i),interpLongYear(i),interpLatYear(j),interpLongYear(j),theta1,theta2,a);
        end
    end
    %toc;
    
    %tic;
    val = val + sum(log(eig(covObs + sigma^2*eye(nRes)))) + interpResYear'*((covObs + sigma^2*eye(nRes))\interpResYear) + log(2*pi)*nRes;
    %toc;
    
end

val = 0.5*val;

disp(val);