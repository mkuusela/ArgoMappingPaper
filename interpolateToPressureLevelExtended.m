%Interpolate raw data to a given pressure level

close all;
clear;

month = 2;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

load(['./Data/Argo_data_aggr_',num2str(month,'%02d'),'_extended.mat']);

interpTemp = zeros(nProf,1);

for iProf = 1:nProf
    interpTemp(iProf) = interp1(profPresAggr{iProf},profTempAggr{iProf},presLevel);
end

nInterp = sum(~isnan(interpTemp));
disp(nInterp);

mask = find(~isnan(interpTemp)); % Find non-NaN interpolated values

interpYear = profYearAggr(mask);
interpJulDay = profJulDayAggr(mask);
interpLat = profLatAggr(mask);
interpLong = profLongAggr(mask);
interpFloatID = profFloatIDAggr(mask);
interpTemp = interpTemp(mask);

% Random permutation of the plotting order
%rng(12345);
%idx = randperm(nInterp);
idx = 1:nInterp;

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 180 0]);
tightmap;
load coast;
plotm(lat,long,'k');
mlabel('off');
plabel('off');

scatterm(interpLat(idx),interpLong(idx),[],interpTemp(idx),'x');

colormap('jet');
colorbar;

caxis(quantile(interpTemp,[0.01,0.99]));

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_all_extended.eps']);

save(['./Results/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_extended.mat'],'interpYear','interpJulDay','interpLat','interpLong','interpFloatID','interpTemp','nInterp','startYear','endYear');