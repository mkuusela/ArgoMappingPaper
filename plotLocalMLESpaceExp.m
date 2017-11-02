close all;
clear;

rEarth = 6371;

month = 2;

startYear = 2007;
endYear = 2016;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

load(['./Results/localMLESpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

mask = ncread('./RG_climatology/RG_ArgoClim_Temperature_2016.nc','BATHYMETRY_MASK',[1 1 25],[Inf Inf 1]);
mask = mask(1:end,:);
mask = [NaN*ones(360,25) mask NaN*ones(360,26)];
mask(mask == 0) = 1;
mask(end+1,:) = mask(end,:);
% mask = ones(size(latGrid));

% Update naming convention
thetasOpt = theta1Opt;
thetaLatOpt = theta2Opt;
thetaLongOpt = theta2Opt.*aOpt;

thetaLatOptKm = thetaLatOpt/360*2*pi*rEarth;
thetaLonOptKm = (thetaLongOpt/360).*cos(latGrid/360*2*pi)*2*pi*rEarth;

%% thetas

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*thetasOpt);

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([0,3]);
    case 300
        caxis([0,1.5]);
    case 1500
        caxis([0,0.05]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/thetas_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% thetaLat

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*thetaLatOptKm);

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([0,2300]);
    case 300
        caxis([0,500]);
    case 1500
        caxis([60,250]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/thetaLat_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% thetaLon

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*thetaLonOptKm);

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([0,3000]);
    case 300
        caxis([0,1600]);
    case 1500
        caxis([0,700]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/thetaLon_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% sigma

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*sigmaOpt);

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([0,0.3]);
    case 300
        caxis([0,0.5]);
    case 1500
        caxis([0,0.08]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/sigma_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% sigma2 / (thetas + sigma2)

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*(sigmaOpt.^2)./(thetasOpt + sigmaOpt.^2));

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([0,0.15]);
    case 300
        caxis([0,0.4]);
    case 1500
        caxis([0,0.5]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/Sigma2VsThetasSigma2_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% thetaLon / thetaLat

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*(thetaLonOptKm./thetaLatOptKm));

load coast;
plotm(lat,long,'k');

colormap('jet');
colorbar;

switch presLevel
    case 10
        caxis([1,2.8]);
    case 300
        caxis([1,5.5]);
    case 1500
        caxis([1,5.5]);
end

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/thetaLonVsThetaLat_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);


%% log(thetas + sigma2)

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*log(thetasOpt + sigmaOpt.^2));

load coast;
plotm(lat,long,'k');

%colormap('jet');
cb = colorbar;

cbar1 = cbrewer('seq','Greys',50);
cbar2 = cbrewer('seq','Purples',50);
cbar3 = cbrewer('seq','Blues',50);
cbar4 = cbrewer('seq','Greens',50);
cbar5 = cbrewer('seq','Oranges',50);
cbar6 = cbrewer('seq','Reds',50);

colormap([cbar1(18:50,:); cbar3(18:50,:); cbar4(18:50,:); cbar5(18:50,:); cbar6(18:50,:)]);

switch presLevel
    case 10
        caxis([-2,1.5]);
        ticks = [log(0.2),log(0.4),log(0.8),log(1.6),log(3.2)];
        tickLabels = {'log(0.2)','log(0.4)','log(0.8)','log(1.6)','log(3.2)'};
    case 300
        caxis([-3,2]);
        ticks = [log(0.07),log(0.21),log(0.63),log(1.89),log(5.67)];
        tickLabels = {'log(0.07)','log(0.21)','log(0.63)','log(1.89)','log(5.67)'};
    case 1500
        caxis([-6.5,-1.5]);
        ticks = [log(0.002),log(0.006),log(0.018),log(0.054),log(0.162)];
        tickLabels = {'log(0.002)','log(0.006)','log(0.018)','log(0.054)','log(0.162)'};
end

set(cb,'Ticks',ticks,'TickLabels',tickLabels);

cb.Label.String = 'Log total variance ((°C)²)';

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/thetasPlusSigma2_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% corr, deltaLat = 800 km

nGrid = numel(latGrid);

deltaLat = 360/(2*pi*rEarth) * 800;

corrLat800 = zeros(size(latGrid));
for iGrid = 1:nGrid
    corrLat800(iGrid) = spaceTimeCovarianceExpGeom(deltaLat,0,0,0,0,0,thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),1)/(thetasOpt(iGrid) + sigmaOpt(iGrid).^2);
end

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,log(mask.*corrLat800));

load coast;
plotm(lat,long,'k');

%colormap('jet');
cb = colorbar;
cbar1 = cbrewer('seq','Greys',50);
cbar2 = cbrewer('seq','Purples',50);
cbar3 = cbrewer('seq','Blues',50);
cbar4 = cbrewer('seq','Greens',50);
cbar5 = cbrewer('seq','Oranges',50);
cbar6 = cbrewer('seq','Reds',50);

colormap([cbar1(18:50,:); cbar3(18:50,:); cbar4(18:50,:); cbar5(18:50,:); cbar6(18:50,:)]);

caxis([-6,-0.15]);

ticks = [log(0.003),log(0.009),log(0.027),log(0.081),log(0.243),log(0.729)];
tickLabels = {'log(0.003)','log(0.009)','log(0.027)','log(0.081)','log(0.243)','log(0.729)'};
set(cb,'Ticks',ticks,'TickLabels',tickLabels);

cb.Label.String = 'Log-correlation';

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/corrLat800_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%% corr, deltaLon = 800 km

nGrid = numel(latGrid);

deltaLon = 360/(2*pi*rEarth) * 800 ./ cos(latGrid/360*2*pi);

corrLon800 = zeros(size(latGrid));
for iGrid = 1:nGrid
    corrLon800(iGrid) = spaceTimeCovarianceExpGeom(0,deltaLon(iGrid),0,0,0,0,thetasOpt(iGrid),thetaLatOpt(iGrid),thetaLongOpt(iGrid),1)/(thetasOpt(iGrid) + sigmaOpt(iGrid).^2);
end

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,log(mask.*corrLon800));

load coast;
plotm(lat,long,'k');

%colormap('jet');
cb = colorbar;
cbar1 = cbrewer('seq','Greys',50);
cbar2 = cbrewer('seq','Purples',50);
cbar3 = cbrewer('seq','Blues',50);
cbar4 = cbrewer('seq','Greens',50);
cbar5 = cbrewer('seq','Oranges',50);
cbar6 = cbrewer('seq','Reds',50);

colormap([cbar1(18:50,:); cbar3(18:50,:); cbar4(18:50,:); cbar5(18:50,:); cbar6(18:50,:)]);
caxis([-6,-0.15]);

ticks = [log(0.003),log(0.009),log(0.027),log(0.081),log(0.243),log(0.729)];
tickLabels = {'log(0.003)','log(0.009)','log(0.027)','log(0.081)','log(0.243)','log(0.729)'};
set(cb,'Ticks',ticks,'TickLabels',tickLabels);

cb.Label.String = 'Log-correlation';

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/corrLon800_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);