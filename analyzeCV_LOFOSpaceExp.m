close all;
clear;

startYear = 2007;
endYear = 2016;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

month = 2;

load(['./Results/CV_LOFOPredsSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);

CVYears = CVStartYear:CVEndYear;
nCVYear = CVEndYear - CVStartYear + 1;

interpLatAggr = cell(1,nCVYear);
interpLongAggr = cell(1,nCVYear);
interpResAggr = cell(1,nCVYear);

for iCVYear = 1:nCVYear

    S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'.mat']);
    interpLatAggr{iCVYear} = S.interpLatYear';
    interpLongAggr{iCVYear} = S.interpLongYear';
    interpResAggr{iCVYear} = S.interpResYear;
    
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

save(['./Results/CV_LOFOResultsSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'MSPEAll','Q3SPEAll','MdSPEAll','MAPEAll','MdAPEAll');

%% Pull

interpLatAll = cell2mat(interpLatAggr');
interpLongAll = cell2mat(interpLongAggr');
interpResAll = cell2mat(interpResAggr');
predsAll = cell2mat(preds');
predVarianceAll = cell2mat(predVariance');

pull = (predsAll - interpResAll) ./ sqrt(predVarianceAll);

save(['./Results/pullLOFOSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'pull');

%% Coverage

nRes = length(interpResAll);

cover68 = zeros(nRes,1);
lengths68 = zeros(nRes,1);
for iRes = 1:nRes
    intLb = predsAll(iRes) - sqrt(predVarianceAll(iRes));
    intUb = predsAll(iRes) + sqrt(predVarianceAll(iRes));
    cover68(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths68(iRes) = intUb - intLb;
end
coverage68 = mean(cover68);
meanLength68 = mean(lengths68);
medianLength68 = median(lengths68);
disp(coverage68);
disp(meanLength68);
disp(medianLength68);

cover95 = zeros(nRes,1);
lengths95 = zeros(nRes,1);
alpha = 1-0.95;
n95 = norminv(1-alpha/2,0,1);
for iRes = 1:nRes
    intLb = predsAll(iRes) - n95 * sqrt(predVarianceAll(iRes));
    intUb = predsAll(iRes) + n95 * sqrt(predVarianceAll(iRes));
    cover95(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths95(iRes) = intUb - intLb;
end
coverage95 = mean(cover95);
meanLength95 = mean(lengths95);
medianLength95 = median(lengths95);
disp(coverage95);
disp(meanLength95);
disp(medianLength95);

cover99 = zeros(nRes,1);
lengths99 = zeros(nRes,1);
alpha = 1-0.99;
n99 = norminv(1-alpha/2,0,1);
for iRes = 1:nRes
    intLb = predsAll(iRes) - n99 * sqrt(predVarianceAll(iRes));
    intUb = predsAll(iRes) + n99 * sqrt(predVarianceAll(iRes));
    cover99(iRes) = (intLb <= interpResAll(iRes) & interpResAll(iRes) <= intUb);
    lengths99(iRes) = intUb - intLb;
end
coverage99 = mean(cover99);
meanLength99 = mean(lengths99);
medianLength99 = median(lengths99);
disp(coverage99);
disp(meanLength99);
disp(medianLength99);

save(['./Results/coverageLOFOSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'coverage68','meanLength68','medianLength68','coverage95','meanLength95','medianLength95','coverage99','meanLength99','medianLength99');