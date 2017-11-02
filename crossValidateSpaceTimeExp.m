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

windowSize = 10;

load(['./Results/localMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(windowSize),'.mat']);

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

    %parfor_progress(nLeaveOut);

    tic;
    parfor iLeaveOut = 1:nLeaveOut
    %for iLeaveOut = 1:nLeaveOut

        predLat = interpLatYear(leaveOutIdxYear(iLeaveOut));
        predLong = interpLongYear(leaveOutIdxYear(iLeaveOut));
        predJulDay = interpJulDayYear(leaveOutIdxYear(iLeaveOut));

        windowSize = 10;

        latMin = predLat - windowSize;
        latMax = predLat + windowSize;
        longMin = predLong - windowSize;
        longMax = predLong + windowSize;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);

        idx(idx == leaveOutIdxYear(iLeaveOut)) = [];

        interpLatYearSel = interpLatYear(idx);
        interpLongYearSel = interpLongYear(idx);
        interpJulDayYearSel = interpJulDayYear(idx);
        interpResYearSel = interpResYear(idx);

        nResSel = length(interpResYearSel);

        % Find grid cell that is closest to the prediction point
        [~,iLat] = min(abs(predLat - latGrid(1,:)));
        [~,iLong] = min(abs(predLong - longGrid(:,1)));
        iGrid = sub2ind(size(latGrid),iLong,iLat);

        covObs = zeros(nResSel,nResSel);

        for i = 1:nResSel
            for j = 1:nResSel
                covObs(i,j) = spaceTimeCovarianceExpGeom(interpLatYearSel(i),interpLongYearSel(i),interpJulDayYearSel(i),interpLatYearSel(j),interpLongYearSel(j),interpJulDayYearSel(j),thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),thetatOpt(iGrid));
            end
        end

        covGridObs = zeros(1,nResSel);

        for iRes = 1:nResSel
            covGridObs(iRes) = spaceTimeCovarianceExpGeom(predLat,predLong,predJulDay,interpLatYearSel(iRes),interpLongYearSel(iRes),interpJulDayYearSel(iRes),thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),thetatOpt(iGrid));
        end

        predsYear(iLeaveOut) = covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nResSel))\interpResYearSel);

        predVarianceYear(iLeaveOut) = thetasOpt(iGrid) + sigmaOpt(iGrid)^2 - covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nResSel))\(covGridObs'));

        %parfor_progress;

    end
    toc;

    %parfor_progress(0);
    
    preds{iCVYear} = predsYear;
    predVariance{iCVYear} = predVarianceYear;
    leaveOutIdx{iCVYear} = leaveOutIdxYear;

end

save(['./Results/CVPredsSpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat'],'preds','predVariance','leaveOutIdx','CVStartYear','CVEndYear');
