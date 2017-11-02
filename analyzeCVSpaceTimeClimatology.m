close all;
clear;

startYear = 2007;
endYear = 2016;

CVStartYear = 2007;
CVEndYear = 2016;

presLevel = 300;
%presLevel = 10;
%presLevel = 1500;

month = 2;

CV = load(['./Results/CVPredsSpaceExpExtended_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
leaveOutIdx = CV.leaveOutIdx;

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

save(['./Results/CVResultsSpaceTimeClimatology_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'MSPEAll','Q3SPEAll','MdSPEAll','MAPEAll','MdAPEAll');