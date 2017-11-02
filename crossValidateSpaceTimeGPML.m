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

north = load(['./Results/localMLESpaceTimeGPMLNorth_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);
south = load(['./Results/localMLESpaceTimeGPMLSouth_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

latGrid = [south.latGrid north.latGrid(:,2:end)];
longGrid = [south.longGrid north.longGrid(:,2:end)];
nuOpt = [south.nuOpt north.nuOpt(:,2:end)];
sigmaOpt = [south.sigmaOpt north.sigmaOpt(:,2:end)];
thetaLatOpt = [south.thetaLatOpt north.thetaLatOpt(:,2:end)];
thetaLongOpt = [south.thetaLongOpt north.thetaLongOpt(:,2:end)];
thetasOpt = [south.thetasOpt north.thetasOpt(:,2:end)];
thetatOpt = [south.thetatOpt north.thetatOpt(:,2:end)];

nCVYear = CVEndYear - CVStartYear + 1;

preds = cell(1,nCVYear);
predVariance = cell(1,nCVYear);
predNu = cell(1,nCVYear);
predSigma = cell(1,nCVYear);
leaveOutIdx = cell(1,nCVYear);

CVYears = CVStartYear:CVEndYear;

%parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))

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
    predNuYear = zeros(nLeaveOut,1);
    predSigmaYear = zeros(nLeaveOut,1);

    %parfor_progress(nLeaveOut);

    tic;
    %parfor iLeaveOut = 1:nLeaveOut
    for iLeaveOut = 1:nLeaveOut

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
        
        if isnan(nuOpt(iGrid)) % Optimization had failed at the nearest grid point so parameter values are unavailable
            predsYear(iLeaveOut) = NaN;
            predVarianceYear(iLeaveOut) = NaN;
            predNuYear(iLeaveOut) = NaN;
            predSigmaYear(iLeaveOut) = NaN;
            
            continue;
        end

        covfunc = {@covMaternard, 1};
        likfunc = @likT;
        hyp.cov = [log(thetaLatOpt(iGrid)); log(thetaLongOpt(iGrid)); log(thetatOpt(iGrid)); log(sqrt(thetasOpt(iGrid)))];
        hyp.lik = [log(nuOpt(iGrid)-1); log(sigmaOpt(iGrid))];
        [~,~,predsYear(iLeaveOut),predVarianceYear(iLeaveOut)] = gp(hyp, @infLaplace, [], covfunc, likfunc, [interpLatYearSel' interpLongYearSel' interpJulDayYearSel'], interpResYearSel, [predLat,predLong,predJulDay]);
        
        predNuYear(iLeaveOut) = nuOpt(iGrid);
        predSigmaYear(iLeaveOut) = sigmaOpt(iGrid);
        
        %parfor_progress;

    end
    toc;

    %parfor_progress(0);
    
    preds{iCVYear} = predsYear;
    predVariance{iCVYear} = predVarianceYear;
    predNu{iCVYear} = predNuYear;
    predSigma{iCVYear} = predSigmaYear;
    leaveOutIdx{iCVYear} = leaveOutIdxYear;

end

save(['./Results/CVPredsSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'preds','predVariance','predNu','predSigma','leaveOutIdx');
