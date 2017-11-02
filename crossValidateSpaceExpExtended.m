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

load(['./Results/localMLESpaceExpExtended_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

nCVYear = CVEndYear - CVStartYear + 1;

preds = cell(1,nCVYear);
predVariance = cell(1,nCVYear);
leaveOutIdx = cell(1,nCVYear);

CVYears = CVStartYear:CVEndYear;

parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))

for iCVYear = 1:nCVYear
    
    disp(CVYears(iCVYear));

    S = load(['./Results/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'_extended.mat']);

    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpJulDayYear = S.interpJulDayYear;
    interpResYear = S.interpResYear;

    startJulDay = datenum(CVYears(iCVYear),month,1,0,0,0);
    endJulDay = datenum(CVYears(iCVYear),month+1,1,0,0,0);

    leaveOutIdxYear = find(interpJulDayYear >= startJulDay & interpJulDayYear <= endJulDay);

    nLeaveOut = length(leaveOutIdxYear);

    predsYear = zeros(nLeaveOut,1);
    predVarianceYear = zeros(nLeaveOut,1);

    parfor_progress(nLeaveOut);

    tic;
    parfor iLeaveOut = 1:nLeaveOut
    %for iLeaveOut = 1:nLeaveOut

        predLat = interpLatYear(leaveOutIdxYear(iLeaveOut));
        predLong = interpLongYear(leaveOutIdxYear(iLeaveOut));

        windowSize = 10;

        latMin = predLat - windowSize;
        latMax = predLat + windowSize;
        longMin = predLong - windowSize;
        longMax = predLong + windowSize;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);

        idx(idx == leaveOutIdxYear(iLeaveOut)) = [];

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
    leaveOutIdx{iCVYear} = leaveOutIdxYear;

end

save(['./Results/CVPredsSpaceExpExtended_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'preds','predVariance','leaveOutIdx');
