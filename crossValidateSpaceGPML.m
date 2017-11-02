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

load(['./Results/localMLESpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

nCVYear = CVEndYear - CVStartYear + 1;

preds = cell(1,nCVYear);
predVariance = cell(1,nCVYear);
predNu = cell(1,nCVYear);
predSigma = cell(1,nCVYear);

CVYears = CVStartYear:CVEndYear;

%parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))

for iCVYear = 1:nCVYear
    
    disp(CVYears(iCVYear));

    S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'.mat']);

    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpResYear = S.interpResYear;

    nRes = length(interpResYear);

    predsYear = zeros(nRes,1);
    predVarianceYear = zeros(nRes,1);
    predNuYear = zeros(nRes,1);
    predSigmaYear = zeros(nRes,1);

    parfor_progress(nRes);

    tic;
    %parfor iLeaveOut = 1:nRes
    for iLeaveOut = 1:nRes

        predLat = interpLatYear(iLeaveOut);
        predLong = interpLongYear(iLeaveOut);

        windowSize = 10;

        latMin = predLat - windowSize;
        latMax = predLat + windowSize;
        longMin = predLong - windowSize;
        longMax = predLong + windowSize;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);

        idx(idx == iLeaveOut) = [];

        interpLatYearSel = interpLatYear(idx);
        interpLongYearSel = interpLongYear(idx);
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
        hyp.cov = [log(thetaLatOpt(iGrid)); log(thetaLongOpt(iGrid)); log(sqrt(thetasOpt(iGrid)))];
        hyp.lik = [log(nuOpt(iGrid)-1); log(sigmaOpt(iGrid))];
        [~,~,predsYear(iLeaveOut),predVarianceYear(iLeaveOut)] = gp(hyp, @infLaplace, [], covfunc, likfunc, [interpLatYearSel' interpLongYearSel'], interpResYearSel, [predLat,predLong]);
        
        predNuYear(iLeaveOut) = nuOpt(iGrid);
        predSigmaYear(iLeaveOut) = sigmaOpt(iGrid);

        parfor_progress;

    end
    toc;

    parfor_progress(0);
    
    preds{iCVYear} = predsYear;
    predVariance{iCVYear} = predVarianceYear;
    predNu{iCVYear} = predNuYear;
    predSigma{iCVYear} = predSigmaYear;

end

save(['./Results/CVPredsSpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat'],'preds','predVariance','predNu','predSigma','CVStartYear','CVEndYear');