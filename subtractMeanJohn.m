close all;
clear;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

switch presLevel
    case 10
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_0005-0015ni_padj_300.dat');
    case 300
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_0290-0310ni_padj_300.dat');
    case 1500
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_1450-1550ni_padj_300.dat');
end

%%

annualMean = reshape(meanFields(:,1),[2160,1080])';

annualMean(annualMean == -99.999) = NaN;

month = 2;

monthlyMean = reshape(meanFields(:,month+1),[2160,1080])';

monthlyMean(monthlyMean == -99.999) = NaN;

clear meanFields;

%%

latBins = linspace(-90,90,1080+1);
latBinMidpoints = (latBins(1:end-1)+latBins(2:end))/2;

longBins = linspace(20,380,2160+1);
longBinMidpoints = (longBins(1:end-1)+longBins(2:end))/2;

%%

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 180 0]);
tightmap;
mlabel('off');
plabel('off');

surfm(latBinMidpoints,longBinMidpoints,monthlyMean);

colormap(jet(1000));
colorbar;

load coast;
plotm(lat,long,'k');

cAxisLims = caxis;

drawnow;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/monthlyMean_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);

%%

load(['./Results/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'.mat']);

% Random permutation of the plotting order
%rng(12345);
%idx = randperm(nInterp);
idx = 1:nInterp;

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 180 0]);
tightmap;
mlabel('off');
plabel('off');

load coast;
plotm(lat,long,'k');

scatterm(interpLat(idx),interpLong(idx),[],interpTemp(idx),'x');

caxis(cAxisLims);

colormap(jet);
colorbar;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_all.eps']);

%% Fitted values

interpTempHat = zeros(nInterp,1);

for iInterp = 1:nInterp
    
    idxLat = find(latBins < interpLat(iInterp),1,'last');
    idxLong = find(longBins < interpLong(iInterp),1,'last');
    
    interpTempHat(iInterp) = monthlyMean(idxLat,idxLong);
end

figure;
handle = worldmap('World');
setm(handle, 'Origin', [0 180 0]);
tightmap;
mlabel('off');
plabel('off');

load coast;
plotm(lat,long,'k');

scatterm(interpLat,interpLong,[],interpTempHat,'x');

caxis(cAxisLims);

colormap(jet);
colorbar;

%% Annual residuals

interpRes = interpTemp - interpTempHat;

for iYear = startYear:endYear

    mask = (interpYear == iYear & ~isnan(interpRes'));
    
    interpLatYear = interpLat(mask);
    interpLongYear = interpLong(mask);
    interpFloatIDYear = interpFloatID(mask);
    interpJulDayYear = interpJulDay(mask);
    interpResYear = interpRes(mask);
    
    cLimit = max(abs(quantile(interpResYear,[0.01 0.99])));

    figure;
    handle = worldmap('World');
    setm(handle, 'Origin', [0 180 0]);
    tightmap;
    mlabel('off');
    plabel('off');

    load coast;
    plotm(lat,long,'k');
    
    scatterm(interpLatYear,interpLongYear,[],interpResYear,'x');

    title([num2str(presLevel),' db, ',num2str(month),'/',num2str(iYear)]);
    
    colormap('jet');
    colorbar;

    caxis([-cLimit,cLimit]);
    
    set(gcf,'units','centimeters')
    set(gcf,'pos',[0 0 22.5 15])
    set(gcf,'paperunits',get(gcf,'units')) 
    set(gcf,'paperpos',get(gcf,'pos'))
    print('-depsc2',['./Figures/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'.eps']);

    save(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'.mat'],'interpResYear','interpLatYear','interpLongYear','interpFloatIDYear','interpJulDayYear');

end