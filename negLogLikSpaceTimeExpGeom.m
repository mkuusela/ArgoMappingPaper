function val = negLogLikSpaceTimeExpGeom(params,interpLatAggr,interpLongAggr,interpJulDayAggr,interpResAggr)

thetas = exp(params(1));
thetaLat = exp(params(2));
thetaLong = exp(params(3));
thetat = exp(params(4));
sigma = exp(params(5));

disp([thetas,thetaLat,thetaLong,thetat,sigma]);

largeVal = 1e10;

if ~(all([thetas,thetaLat,thetaLong,thetat,sigma] < largeVal))
    val = NaN;
    disp(val);
    return;
end

if ~(all([thetas,thetaLat,thetaLong,thetat,sigma] > eps))
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
    interpJulDayYear = interpJulDayAggr{iYear};
    interpResYear = interpResAggr{iYear};
    
    nRes = length(interpResYear);
    %disp(nRes);
    
    covObs = zeros(nRes,nRes);
    
    %tic;
    for i = 1:nRes
        %disp(i);
        for j = 1:nRes
            covObs(i,j) = spaceTimeCovarianceExpGeom(interpLatYear(i),interpLongYear(i),interpJulDayYear(i),interpLatYear(j),interpLongYear(j),interpJulDayYear(j),thetas,thetaLat,thetaLong,thetat);
        end
    end
    %toc;
    
    %tic;
    val = val + sum(log(eig(covObs + sigma^2*eye(nRes)))) + (interpResYear)'*((covObs + sigma^2*eye(nRes))\interpResYear) + log(2*pi)*nRes;
    %toc;
    
end

val = 0.5*val;

disp(val);