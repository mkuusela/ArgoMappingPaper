CVStartYear = 2007;
CVEndYear = 2016;
month = 2;

%presLevel = 10;
%presLevel = 300;
presLevel = 1500;

fileID = fopen(['./Results/CVTableCoverage_',num2str(presLevel),'_',num2str(month,'%02d'),'.dat'],'w');

fprintf(fileID,'%1.0f%s ',68,'\:\%');

for iMethod = 1:5
    switch iMethod
        case 1 % RG
            load(['./Results/coverageSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Reference');
        case 2 % SpaceExp
            load(['./Results/coverageSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Gaussian nugget');
        case 3 % SpaceTimeExp
            load(['./Results/coverageSpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Gaussian nugget');
        case 4 % SpaceGPML
            load(['./Results/coverageSpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Student nugget');
        case 5 % SpaceTimeGPML
            load(['./Results/coverageSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Student nugget');
    end
    fprintf(fileID,'& %1.4f & %1.4f & %1.4f \\\\\n',coverage68,meanLength68,medianLength68);
end

fprintf(fileID,'%s\n','\midrule');

fprintf(fileID,'%1.0f%s ',95,'\:\%');

for iMethod = 1:5
    switch iMethod
        case 1 % RG
            load(['./Results/coverageSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Reference');
        case 2 % SpaceExp
            load(['./Results/coverageSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Gaussian nugget');
        case 3 % SpaceTimeExp
            load(['./Results/coverageSpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Gaussian nugget');
        case 4 % SpaceGPML
            load(['./Results/coverageSpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Student nugget');
        case 5 % SpaceTimeGPML
            load(['./Results/coverageSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Student nugget');
    end
    fprintf(fileID,'& %1.4f & %1.4f & %1.4f \\\\\n',coverage95,meanLength95,medianLength95);
end

fprintf(fileID,'%s\n','\midrule');

fprintf(fileID,'%1.0f%s ',99,'\:\%');

for iMethod = 1:5
    switch iMethod
        case 1 % RG
            load(['./Results/coverageSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Reference');
        case 2 % SpaceExp
            load(['./Results/coverageSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Gaussian nugget');
        case 3 % SpaceTimeExp
            load(['./Results/coverageSpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Gaussian nugget');
        case 4 % SpaceGPML
            load(['./Results/coverageSpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space, Student nugget');
        case 5 % SpaceTimeGPML
            load(['./Results/coverageSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            fprintf(fileID,'& %s ','Space-time, Student nugget');
    end
    fprintf(fileID,'& %1.4f & %1.4f & %1.4f \\\\\n',coverage99,meanLength99,medianLength99);
end

fclose(fileID);