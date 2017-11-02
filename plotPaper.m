close all;

clear;

month = 2;

presLevel = 300;
%presLevel = 10;
%presLevel = 1500;

year = 2012;

%%

load(['./Results/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'.mat']);

% Random permutation of the plotting order
%rng(12345);
%idx = randperm(nInterp);
%idx = 1:nInterp;

idx = (interpYear == year);

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 200 0]);
tightmap;
mlabel('off');
plabel('off');

load coast;
plotm(lat,long,'k');

scatterm(interpLat(idx),interpLong(idx),30,interpTemp(idx),'.');

colormap(jet);
h = colorbar;
h.Label.String = 'Temperature (°C)';

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(year),'.eps']);