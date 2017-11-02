close all;
clear;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

month = 2;

%%

switch presLevel
    case 10
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_0005-0015ni_padj_300.dat');
    case 300
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_0290-0310ni_padj_300.dat');
    case 1500
        meanFields = importdata('./Argo_data_John/fil_XXXX_pa99_p2xp2_SSSS-DDDDni_padj_300.dat/fil_temp_pa99_p2xp2_1450-1550ni_padj_300.dat');
end

monthlyMeans = zeros([1080,2160,12]);

for iMonth = 1:12

    monthlyMeans(:,:,iMonth) = reshape(meanFields(:,iMonth+1),[2160,1080])';

end

monthlyMeans(monthlyMeans == -99.999) = NaN;

clear meanFields;

latBins = linspace(-90,90,1080+1);
latBinMidpoints = (latBins(1:end-1)+latBins(2:end))/2;

longBins = linspace(20,380,2160+1);
longBinMidpoints = (longBins(1:end-1)+longBins(2:end))/2;

%%

nTimeGrid = 20;
%nTimeGrid = 200;

meanTimeGrid = zeros([1080,2160,nTimeGrid]);
betaHat = zeros([1080,2160,13]);

for iLat = 1:1080
    
    disp(iLat);
    
    for iLong = 1:2160

        y = squeeze(monthlyMeans(iLat,iLong,:));

        m = (1:12)-0.5;
        periods = 1:6;

        vals = m'*periods;

        X = [ones(12,1) sin(2*pi*vals/12) cos(2*pi*vals/12)];

        %betaHat(iLat,iLong,:) = X\y; % Gives sparsest solution?
        betaHat(iLat,iLong,:) = pinv(X)*y; % Gives minimum norm solution

        mGrid = linspace(0,12,nTimeGrid);

        valsGrid = mGrid'*periods;

        XGrid = [ones(nTimeGrid,1) sin(2*pi*valsGrid/12) cos(2*pi*valsGrid/12)];

        yGrid = XGrid*squeeze(betaHat(iLat,iLong,:));
        
        meanTimeGrid(iLat,iLong,:) = yGrid;

%         figure;
%         hold on;
%         plot(m,y,'.-b');
%         plot(mGrid,yGrid,'-k');
%         hold off;

    end
end

clear monthlyMeans;

save(['./Results/spaceTimeMeanFieldCoeffs_presLevel',num2str(presLevel),'.mat'],'betaHat','latBins','longBins');
save(['./Results/spaceTimeMovie_presLevel',num2str(presLevel),'.mat'],'nTimeGrid','meanTimeGrid');

%%

% load(['./Results/spaceTimeMovie_presLevel',num2str(presLevel),'.mat']);
% 
% figure;
% pause;
% % handle = worldmap('World');
% % setm(handle, 'Origin', [0 180 0]);
% % tightmap;
% % mlabel('off');
% % plabel('off');
% 
% for iTime = [1:nTimeGrid-1 1:nTimeGrid-1 1:nTimeGrid-1 1:nTimeGrid-1 1:nTimeGrid]
%     %surfm(latBinMidpoints,longBinMidpoints,meanTimeGrid(:,:,iTime));
%     imagesc([-90,90],[20,380],flipud(meanTimeGrid(:,:,iTime)));
%     colormap(jet(1000));
%     title(num2str(iTime));
%     caxis([min(min(min(meanTimeGrid))),max(max(max(meanTimeGrid)))]);
%     colorbar;
%     drawnow;
%     pause(0.1);
% end

%%

load(['./Results/spaceTimeMeanFieldCoeffs_presLevel',num2str(presLevel),'.mat']);

load(['./Results/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_extended.mat']);

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

caxis(quantile(interpTemp,[0.01,0.99]));

colormap(jet);
colorbar;

set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 22.5 15])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
%print('-depsc2',['./Figures/interpolated_',num2str(presLevel),'_',num2str(month,'%02d'),'_all.eps']);

%% Fitted values

load(['./Results/spaceTimeMeanFieldCoeffs_presLevel',num2str(presLevel),'.mat']);

interpTempHat = zeros(nInterp,1);

for iInterp = 1:nInterp
    
    idxLat = find(latBins < interpLat(iInterp),1,'last');
    idxLong = find(longBins < interpLong(iInterp),1,'last');
    
    m = interpJulDay(iInterp) - datenum(interpYear(iInterp),1,0,0,0,0);
    m = m/365*12;
    
    periods = 1:6;

    vals = m'*periods;

    x = [1 sin(2*pi*vals/12) cos(2*pi*vals/12)];
    
    interpTempHat(iInterp) = x*squeeze(betaHat(idxLat,idxLong,:));
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

colormap(jet);
colorbar;

%% Annual residuals

interpRes = interpTemp - interpTempHat;

for iYear = startYear:endYear

    mask = (interpYear == iYear & ~isnan(interpRes'));
    
    disp(sum(mask));
    
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
    
    drawnow;
    
    set(gcf,'units','centimeters')
    set(gcf,'pos',[0 0 22.5 15])
    set(gcf,'paperunits',get(gcf,'units')) 
    set(gcf,'paperpos',get(gcf,'pos'))
    print('-depsc2',['./Figures/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'_extended.eps']);

    save(['./Results/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'_extended.mat'],'interpResYear','interpLatYear','interpLongYear','interpFloatIDYear','interpJulDayYear');

end