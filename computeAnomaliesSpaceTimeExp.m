close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;

predYear = 2012;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

windowSize = 10;

%%

load(['./Results/localMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(windowSize),'.mat']);

nGrid = numel(latGrid);

midJulDay = datenum(predYear,month,15,12,0,0); % February 15, 2012 at noon (midpoint of the month since 2012 was a leap year)

predGrid = zeros(size(latGrid));
predVarianceGrid = zeros(size(latGrid));

parfor_progress(nGrid);

tic;
parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))
parfor iGrid = 1:nGrid
%for iGrid = 1:nGrid
    
    predLat = latGrid(iGrid);
    predLong = longGrid(iGrid);

    latMin = predLat - windowSize;
    latMax = predLat + windowSize;
    longMin = predLong - windowSize;
    longMax = predLong + windowSize;
    
    S = load(['./Results/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'_extended.mat']);
    
    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpJulDayYear = S.interpJulDayYear;
    interpResYear = S.interpResYear;
    
    idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);
    
    interpLatYear = interpLatYear(idx);
    interpLongYear = interpLongYear(idx);
    interpJulDayYear = interpJulDayYear(idx);
    interpResYear = interpResYear(idx);
    
    nRes = length(interpResYear);
    
    covObs = zeros(nRes,nRes);
    for i = 1:nRes
        for j = 1:nRes
            covObs(i,j) = spaceTimeCovarianceExpGeom(interpLatYear(i),interpLongYear(i),interpJulDayYear(i),interpLatYear(j),interpLongYear(j),interpJulDayYear(j),thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),thetatOpt(iGrid));
        end
    end

    covGridObs = zeros(1,nRes);
    for iRes = 1:nRes
        covGridObs(iRes) = spaceTimeCovarianceExpGeom(predLat,predLong,midJulDay,interpLatYear(iRes),interpLongYear(iRes),interpJulDayYear(iRes),thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),thetatOpt(iGrid));
    end

    predGrid(iGrid) = covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nRes))\interpResYear);
    
    predVarianceGrid(iGrid) = thetasOpt(iGrid) + sigmaOpt(iGrid)^2 - covGridObs*((covObs + sigmaOpt(iGrid)^2*eye(nRes))\(covGridObs'));

    parfor_progress;
    
end
toc;

parfor_progress(0);

save(['./Results/anomalySpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(predYear),'.mat'],'predGrid','predVarianceGrid','latGrid','longGrid');

%%

clear interpResYear; % To suppress parfor error

load(['./Results/anomalySpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(predYear),'.mat']);
load(['./Results/localMLESpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(windowSize),'.mat']);

mask = ncread('./RG_climatology/RG_ArgoClim_Temperature_2016.nc','BATHYMETRY_MASK',[1 1 25],[Inf Inf 1]);
mask = [NaN*ones(360,25) mask NaN*ones(360,26)];
mask(mask == 0) = 1;
mask(end+1,:) = mask(end,:);
%mask = ones(size(latGrid));

%%
figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*predGrid);

load coast;
plotm(lat,long,'k');

%colormap('jet');

h = colorbar;
h.Label.String = 'Temperature anomaly (°C)';

switch presLevel
    case 10
        caxis([-1.1,1.1]);
    case 300
        caxis([-1.1,1.1]);
    case 1500
        caxis([-0.15,0.15]);
end

cLims = caxis;
colormap(darkb2r(cLims(1),cLims(2)));

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/anomalyFieldZoomed_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.eps']);

%%
figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*sqrt(predVarianceGrid));

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

caxis([0,0.5]);

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/krigingVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.eps']);

%%
figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*(predVarianceGrid./(thetasOpt+sigmaOpt.^2)));

load coast;
plotm(lat,long,'k');

colormap('jet');
h = colorbar;
h.Label.String = 'Post-data variance / pre-data variance';

caxis([0,1]);

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/krigingVarianceVsMarginalVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.eps']);
