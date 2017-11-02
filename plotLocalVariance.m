close all;
clear;

rEarth = 6371;

month = 2;

startYear = 2007;
endYear = 2016;
%startYear = 2010;
%endYear = 2010;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

load(['./Results/localVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

mask = ncread('./RG_climatology/RG_ArgoClim_Temperature_2016.nc','BATHYMETRY_MASK',[1 1 25],[Inf Inf 1]);
mask = mask(1:end,:);
mask = [NaN*ones(360,25) mask NaN*ones(360,26)];
mask(mask == 0) = 1;
mask(end+1,:) = mask(end,:);
% mask = ones(size(latGrid));

%% Log of local variance

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latGrid,longGrid,mask.*log(varGrid));

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

cb.Label.String = 'Log empirical variance ((°C)²)';

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/localVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);