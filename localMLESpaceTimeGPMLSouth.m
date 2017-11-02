close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;
% startYear = 2010;
% endYear = 2010;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

%[latGrid,longGrid] = meshgrid(linspace(0,90,91),linspace(20,380,361)); % Northern hemisphere
[latGrid,longGrid] = meshgrid(linspace(-90,0,91),linspace(20,380,361)); % Southern hemisphere
%[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(20,380,361)); % Whole globe

nGrid = numel(latGrid);

%disp(nGrid);

windowSize = 10;

% Load initial values for the covariance parameters from the Gaussian nugget fit
S = load(['./Results/localMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(windowSize),'.mat']);
thetasInit = S.thetasOpt;
thetasInit = thetasInit(:,1:91);
thetaLatInit = S.thetaLatOpt;
thetaLatInit = thetaLatInit(:,1:91);
thetaLongInit = S.thetaLongOpt;
thetaLongInit = thetaLongInit(:,1:91);
thetatInit = S.thetatOpt;
thetatInit = thetatInit(:,1:91);
sigmaInit = S.sigmaOpt;
sigmaInit = sigmaInit(:,1:91);

thetasOpt = zeros(size(latGrid));
thetaLatOpt = zeros(size(latGrid));
thetaLongOpt = zeros(size(latGrid));
thetatOpt = zeros(size(latGrid));
sigmaOpt = zeros(size(latGrid));
nuOpt = zeros(size(latGrid));
nll = zeros(size(latGrid));
nResGrid = zeros(size(latGrid));

% Discard previous iterIdx, if it exists
fileName = ['iterIdxLocalMLESpaceTimeGPMLSouth_',num2str(presLevel),'_',num2str(month,'%02d'),'.txt'];
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

    nYear = endYear - startYear + 1;

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
        nuOpt(iGrid) = NaN;
        nll(iGrid) = NaN;
        
        %parfor_progress;
        
        continue;
    end
    
    try

        covfunc = {@covMaternard, 1};
        likfunc = @likT;
        hyp.cov = [log(thetaLatInit(iGrid)); log(thetaLongInit(iGrid)); log(thetatInit(iGrid)); log(sqrt(thetasInit(iGrid)))];
        hyp.lik = [log(4-1);log(1)];
        hyp = minimize(hyp, @gpSeveralYearsSpaceTime, -500, @infLaplace, covfunc, likfunc, interpLatAggr, interpLongAggr, interpJulDayAggr, interpResAggr);

        thetasOpt(iGrid) = exp(hyp.cov(4))^2;
        thetaLatOpt(iGrid) = exp(hyp.cov(1));
        thetaLongOpt(iGrid) = exp(hyp.cov(2));
        thetatOpt(iGrid) = exp(hyp.cov(3));
        sigmaOpt(iGrid) = exp(hyp.lik(2));
        nuOpt(iGrid) = exp(hyp.lik(1))+1;
        nll(iGrid) = gpSeveralYearsSpaceTime(hyp, @infLaplace, covfunc, likfunc, interpLatAggr, interpLongAggr, interpJulDayAggr, interpResAggr);

    catch
        warning('Optimization failed!');
        
        thetasOpt(iGrid) = NaN;
        thetaLatOpt(iGrid) = NaN;
        thetaLongOpt(iGrid) = NaN;
        thetatOpt(iGrid) = NaN;
        sigmaOpt(iGrid) = NaN;
        nuOpt(iGrid) = NaN;
        nll(iGrid) = NaN;
    end
    
    %parfor_progress;
    
end
toc;

%parfor_progress(0);

save(['./Results/localMLESpaceTimeGPMLSouth_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat'],'latGrid','longGrid','thetasOpt','thetaLatOpt','thetaLongOpt','thetatOpt','sigmaOpt','nuOpt','nll','nResGrid');
