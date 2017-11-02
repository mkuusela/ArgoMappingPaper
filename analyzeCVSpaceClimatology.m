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

    SPE{iCVYear} = (interpResAggr{iCVYear}).^2;
    APE{iCVYear} = abs(interpResAggr{iCVYear});

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

save(['./Results/CVResultsSpaceClimatology_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'MSPEAll','Q3SPEAll','MdSPEAll','MAPEAll','MdAPEAll');