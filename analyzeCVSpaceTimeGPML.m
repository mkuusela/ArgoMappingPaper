close all;
clear;

startYear = 2007;
endYear = 2016;

CVStartYear = 2007;
CVEndYear = 2016;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

month = 2;

load(['./Results/CVPredsSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);

CVYears = CVStartYear:CVEndYear;
nCVYear = CVEndYear - CVStartYear + 1;

interpLatAggr = cell(1,nCVYear);
interpLongAggr = cell(1,nCVYear);
interpResAggr = cell(1,nCVYear);

for iCVYear = 1:nCVYear

    S = load(['./Results/residualsJohnSpaceTime_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'_extended.mat']);
    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpResYear = S.interpResYear;
    
    interpLatYear = interpLatYear(leaveOutIdx{iCVYear});
    interpLongYear = interpLongYear(leaveOutIdx{iCVYear});
    interpResYear = interpResYear(leaveOutIdx{iCVYear});
    
    interpLatAggr{iCVYear} = interpLatYear';
    interpLongAggr{iCVYear} = interpLongYear';
    interpResAggr{iCVYear} = interpResYear;
    
end

% Remove NaNs
for iCVYear = 1:nCVYear
    
    nanMask = isnan(preds{iCVYear});
    
    disp([num2str(sum(nanMask)),'/',num2str(length(preds{iCVYear})),'=',num2str(sum(nanMask)/length(preds{iCVYear}))]);
    
    interpLatAggr{iCVYear}(nanMask) = [];
    interpLongAggr{iCVYear}(nanMask) = [];
    interpResAggr{iCVYear}(nanMask) = [];
    preds{iCVYear}(nanMask) = [];
    predVariance{iCVYear}(nanMask) = [];
    predNu{iCVYear}(nanMask) = [];
    predSigma{iCVYear}(nanMask) = [];
    
end

SPE = cell(1,nCVYear);
APE = cell(1,nCVYear);

for iCVYear = 1:nCVYear

    SPE{iCVYear} = (preds{iCVYear}-interpResAggr{iCVYear}).^2;
    APE{iCVYear} = abs(preds{iCVYear}-interpResAggr{iCVYear});

end

MSPE = cellfun(@mean,SPE);
MdSPE = cellfun(@median,SPE);
MAPE = cellfun(@mean,APE);
MdAPE = cellfun(@median,APE);
disp(MSPE);
disp(MdSPE);
disp(MAPE);
disp(MdAPE);

SPEAll = cell2mat(SPE');
MSPEAll = mean(SPEAll);
Q3SPEAll = quantile(SPEAll,0.75);
MdSPEAll = median(SPEAll);
APEAll = cell2mat(APE');
MAPEAll = mean(APEAll);
MdAPEAll = median(APEAll);
disp(MSPEAll);
disp(Q3SPEAll);
disp(MdSPEAll);
disp(MAPEAll);
disp(MdAPEAll);

save(['./Results/CVResultsSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'MSPEAll','Q3SPEAll','MdSPEAll','MAPEAll','MdAPEAll');

%%

interpLatAll = cell2mat(interpLatAggr');
interpLongAll = cell2mat(interpLongAggr');
interpResAll = cell2mat(interpResAggr');
predsAll = cell2mat(preds');
predVarianceAll = cell2mat(predVariance');
predNuAll = cell2mat(predNu');
predSigmaAll = cell2mat(predSigma');

nRes = length(interpResAll);
disp(nRes);

%%
pull = predsAll - interpResAll;

pullUnif = zeros(nRes,1);
tic;
parfor_progress(nRes);
parfor iRes = 1:nRes
    disp(iRes);
    pullUnif(iRes) = normalPlusTcdf(sqrt(predVarianceAll(iRes)),predSigmaAll(iRes),predNuAll(iRes),pull(iRes));
    parfor_progress();
end
parfor_progress(0);
toc;

pullNormal = norminv(pullUnif,0,1);

save(['./Results/pullSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'pullNormal');

%% Coverage

disp('68% level');
cover68 = zeros(nRes,1);
lengths68 = zeros(nRes,1);
parfor iRes = 1:nRes
    %disp(iRes);
    alpha = 1-0.68;
    q68 = normalPlusTQuantile(sqrt(predVarianceAll(iRes)),predSigmaAll(iRes),predNuAll(iRes),1-alpha/2);
    intLb = predsAll(iRes) - q68;
    intUb = predsAll(iRes) + q68;
    cover68(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths68(iRes) = intUb - intLb;
end
coverage68 = mean(cover68);
meanLength68 = mean(lengths68);
medianLength68 = median(lengths68);
disp(coverage68);
disp(meanLength68);
disp(medianLength68);

disp('95% level');
cover95 = zeros(nRes,1);
lengths95 = zeros(nRes,1);
parfor iRes = 1:nRes
    %disp(iRes);
    alpha = 1-0.95;
    q95 = normalPlusTQuantile(sqrt(predVarianceAll(iRes)),predSigmaAll(iRes),predNuAll(iRes),1-alpha/2);
    intLb = predsAll(iRes) - q95;
    intUb = predsAll(iRes) + q95;
    cover95(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths95(iRes) = intUb - intLb;
end
coverage95 = mean(cover95);
meanLength95 = mean(lengths95);
medianLength95 = median(lengths95);
disp(coverage95);
disp(meanLength95);
disp(medianLength95);

disp('99% level');
cover99 = zeros(nRes,1);
lengths99 = zeros(nRes,1);
parfor iRes = 1:nRes
    %disp(iRes);
    alpha = 1-0.99;
    q99 = normalPlusTQuantile(sqrt(predVarianceAll(iRes)),predSigmaAll(iRes),predNuAll(iRes),1-alpha/2);
    intLb = predsAll(iRes) - q99;
    intUb = predsAll(iRes) + q99;
    cover99(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths99(iRes) = intUb - intLb;
end
coverage99 = mean(cover99);
meanLength99 = mean(lengths99);
medianLength99 = median(lengths99);
disp(coverage99);
disp(meanLength99);
disp(medianLength99);

save(['./Results/coverageSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'coverage68','meanLength68','medianLength68','coverage95','meanLength95','medianLength95','coverage99','meanLength99','medianLength99');