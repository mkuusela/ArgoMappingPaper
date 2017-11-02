close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

CVStartYear = 2007;
CVEndYear = 2016;

load(['./Results/localMLESpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

nCVYear = CVEndYear - CVStartYear + 1;

preds = cell(1,nCVYear);
predVariance = cell(1,nCVYear);

CVYears = CVStartYear:CVEndYear;

for iCVYear = 1:nCVYear
    
    disp(CVYears(iCVYear));

    S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'.mat']);

    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpResYear = S.interpResYear;
    interpFloatIDYear = S.interpFloatIDYear;

    nRes = length(interpResYear);

    predsYear = zeros(nRes,1);
    predVarianceYear = zeros(nRes,1);

    parfor_progress(nRes);

    tic;
    parfor iLeaveOut = 1:nRes
    %for iLeaveOut = 1:nRes

        predLat = interpLatYear(iLeaveOut);
        predLong = interpLongYear(iLeaveOut);

        windowSize = 10;

        latMin = predLat - windowSize;
        latMax = predLat + windowSize;
        longMin = predLong - windowSize;
        longMax = predLong + windowSize;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);
        
        sameFloat = (interpFloatIDYear(idx) == interpFloatIDYear(iLeaveOut));

        idx(sameFloat) = [];
        
        interpLatYearSel = interpLatYear(idx);
        interpLongYearSel = interpLongYear(idx);
        interpResYearSel = interpResYear(idx);

        nResSel = length(interpResYearSel);

        % Find grid cell that is closest to the prediction point
        [~,iLat] = min(abs(predLat - latGrid(1,:)));
        [~,iLong] = min(abs(predLong - longGrid(:,1)));
        iGrid = sub2ind(size(latGrid),iLong,iLat);

        covObs = zeros(nResSel,nResSel);

        for i = 1:nResSel
            for j = 1:nResSel
                covObs(i,j) = exponentialCovarianceAnisotropy(interpLatYearSel(i),interpLongYearSel(i),interpLatYearSel(j),interpLongYearSel(j),theta1Opt(iGrid),theta2Opt(iGrid),aOpt(iGrid));
            end
        end

        covGridObs = zeros(1,nResSel);

        for iRes = 1:nResSel
            covGridObs(iRes) = exponentialCovarianceAnisotropy(predLat,predLong,interpLatYearSel(iRes),interpLongYearSel(iRes),theta1Opt(iGrid),theta2Opt(iGrid),aOpt(iGrid));
        end

        predsYear(iLeaveOut) = covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nResSel))\interpResYearSel);

        predVarianceYear(iLeaveOut) = theta1Opt(iGrid) + sigmaOpt(iGrid)^2 - covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nResSel))\(covGridObs'));

        parfor_progress;

    end
    toc;

    parfor_progress(0);
    
    preds{iCVYear} = predsYear;
    predVariance{iCVYear} = predVarianceYear;

end

save(['./Results/CV_LOFOPredsSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat'],'preds','predVariance','CVStartYear','CVEndYear');