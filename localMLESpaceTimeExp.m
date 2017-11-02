close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(20,380,361)); % Whole globe
%[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(20,135,116)); % Indian ocean
%[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(100,290,191)); % Pacific ocean
%[latGrid,longGrid] = meshgrid(linspace(-20,20,41),linspace(100,290,191)); % Equatorial Pacific

nGrid = numel(latGrid);
nYear = endYear - startYear + 1;

%disp(nGrid);

thetasOpt = zeros(size(latGrid));
thetaLatOpt = zeros(size(latGrid));
thetaLongOpt = zeros(size(latGrid));
thetatOpt = zeros(size(latGrid));
sigmaOpt = zeros(size(latGrid));
nll = zeros(size(latGrid));
nResGrid = zeros(size(latGrid));

windowSize = 10;

% Discard previous itearIdx, if it exists
fileName = ['iterIdxLocalMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(windowSize),'.txt'];
fileID = fopen(fileName,'w');
fclose(fileID);

%parfor_progress(nGrid);

tic;
parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))
parfor iGrid = 1:nGrid
%for iGrid = 1:nGrid
    
    %disp(iGrid);
    
    fileID = fopen(fileName,'a');
    fprintf(fileID,'%d \n',iGrid);
    fclose(fileID);

    predLat = latGrid(iGrid);
    predLong = longGrid(iGrid);

    latMin = predLat - windowSize;
    latMax = predLat + windowSize;
    longMin = predLong - windowSize;
    longMax = predLong + windowSize;

    interpLatAggr = cell(1,nYear);
    interpLongAggr = cell(1,nYear);
    interpJulDayAggr = cell(1,nYear);
    interpResAggr = cell(1,nYear);

    for iYear = startYear:endYear

        S = load(['./Results/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'_extended.mat']);
        
        interpLatYear = S.interpLatYear;
        interpLongYear = S.interpLongYear;
        interpJulDayYear = S.interpJulDayYear;
        interpResYear = S.interpResYear;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);

        interpLatAggr{iYear-startYear+1} = interpLatYear(idx)';
        interpLongAggr{iYear-startYear+1} = interpLongYear(idx)';
        interpJulDayAggr{iYear-startYear+1} = interpJulDayYear(idx)';
        interpResAggr{iYear-startYear+1} = interpResYear(idx);

    end
    
    nResGrid(iGrid) = sum(cellfun(@length,interpResAggr));
    
    if nResGrid(iGrid) == 0 % No observations in the window
        
        thetasOpt(iGrid) = NaN;
        thetaLatOpt(iGrid) = NaN;
        thetaLongOpt(iGrid) = NaN;
        thetatOpt(iGrid) = NaN;
        sigmaOpt(iGrid) = NaN;
        nll(iGrid) = NaN;
        
        %parfor_progress;
        
        continue;
    end

    fun = @(params) negLogLikSpaceTimeExpGeom(params,interpLatAggr,interpLongAggr,interpJulDayAggr,interpResAggr);
    
    logThetasInit = log(1);
    logThetaLatInit = log(5);
    logThetaLongInit = log(5);
    logThetatInit = log(5);
    logSigmaInit = log(0.1);
    
    opts = optimoptions(@fminunc,'Algorithm','quasi-newton','MaxFunctionEvaluations',1000);

    [paramOpt,nll(iGrid)] = fminunc(fun,[logThetasInit, logThetaLatInit, logThetaLongInit, logThetatInit, logSigmaInit],opts);
    
    thetasOpt(iGrid) = exp(paramOpt(1));
    thetaLatOpt(iGrid) = exp(paramOpt(2));
    thetaLongOpt(iGrid) = exp(paramOpt(3));
    thetatOpt(iGrid) = exp(paramOpt(4));
    sigmaOpt(iGrid) = exp(paramOpt(5));

    %parfor_progress;
    
end
toc;

%parfor_progress(0);

save(['./Results/localMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(windowSize),'.mat'],'latGrid','longGrid','thetasOpt','thetaLatOpt','thetaLongOpt','thetatOpt','sigmaOpt','nll','nResGrid','nYear');
