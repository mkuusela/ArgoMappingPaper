close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;

predYear = 2012;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

%%
load(['./Results/localMLESpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

nGrid = numel(latGrid);

predGrid = zeros(size(latGrid));
predVarianceGrid = zeros(size(latGrid));

parfor_progress(nGrid);

tic;
%parfor iGrid = 1:nGrid
for iGrid = 1:nGrid
    
    predLat = latGrid(iGrid);
    predLong = longGrid(iGrid);

    windowSize = 10;

    latMin = predLat - windowSize;
    latMax = predLat + windowSize;
    longMin = predLong - windowSize;
    longMax = predLong + windowSize;
    
    S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(predYear),'.mat']);
    
    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpResYear = S.interpResYear;
    
    idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);
    
    interpLatYear = interpLatYear(idx);
    interpLongYear = interpLongYear(idx);
    interpResYear = interpResYear(idx);
    
    covfunc = {@covMaternard, 1};
    likfunc = @likT;
    hyp.cov = [log(thetaLatOpt(iGrid)); log(thetaLongOpt(iGrid)); log(sqrt(thetasOpt(iGrid)))];
    hyp.lik = [log(nuOpt(iGrid)-1); log(sigmaOpt(iGrid))];
    [~,~,predGrid(iGrid),predVarianceGrid(iGrid)] = gp(hyp, @infLaplace, [], covfunc, likfunc, [interpLatYear' interpLongYear'], interpResYear, [predLat,predLong]);
    
    parfor_progress;
    
end
toc;

parfor_progress(0);

save(['./Results/anomalySpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(predYear),'.mat'],'predGrid','predVarianceGrid','nuOpt','sigmaOpt','latGrid','longGrid');

%%

clear interpResYear; % To suppress parfor error

load(['./Results/anomalySpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(predYear),'.mat']);

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

colormap('jet');
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