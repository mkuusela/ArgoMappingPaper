close all;
clear;

month = 2;

predYear = 2012;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

%%
[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(20,380,361));

nGrid = numel(latGrid);

predGrid = zeros(size(latGrid));
postDataVsPreDataVarianceGrid = zeros(size(latGrid));

S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.mat']);

interpLatYear = S.interpLatYear;
interpLongYear = S.interpLongYear;
interpResYear = S.interpResYear;

nRes = length(interpResYear);

covObs = zeros(nRes,nRes);
for i = 1:nRes
    for j = 1:nRes
        covObs(i,j) = spaceCovarianceRG(interpLatYear(i),interpLongYear(i),interpLatYear(j),interpLongYear(j));
    end
end

covObsInvTimesData = (covObs + 0.15*eye(nRes))\interpResYear;
covObsInv = inv(covObs + 0.15*eye(nRes));

parfor_progress(nGrid);

tic;
parfor iGrid = 1:nGrid
%for iGrid = 1:nGrid
    
    %disp(iGrid);

    predLat = latGrid(iGrid);
    predLong = longGrid(iGrid);

    covGridObs = zeros(1,nRes);
    for iRes = 1:nRes
        covGridObs(iRes) = spaceCovarianceRG(predLat,predLong,interpLatYear(iRes),interpLongYear(iRes));
    end

    predGrid(iGrid) = covGridObs*covObsInvTimesData;
    
    postDataVsPreDataVarianceGrid(iGrid) = (1.15 - covGridObs*covObsInv*covGridObs')/1.15;

    parfor_progress;
    
end
toc;

parfor_progress(0);

save(['./Results/anomalySpaceRG_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.mat'],'predGrid','postDataVsPreDataVarianceGrid','latGrid','longGrid');

%%
load(['./Results/anomalySpaceRG_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.mat']);

mask = ncread('./RG_climatology/RG_ArgoClim_Temperature_2016.nc','BATHYMETRY_MASK',[1 1 25],[Inf Inf 1]);
mask = [NaN*ones(360,25) mask NaN*ones(360,26)];
mask(mask == 0) = 1;
mask(end+1,:) = mask(end,:);

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

surfm(latGrid,longGrid,mask.*postDataVsPreDataVarianceGrid);

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