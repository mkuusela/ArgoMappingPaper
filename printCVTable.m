fileID = fopen('./Results/CVTableGaussianNugget.dat','w');

CVStartYear = 2007;
CVEndYear = 2016;
month = 2;
presLevels = [10,300,1500];

for iPresLevel = 1:3
    
    fprintf(fileID,'%1.0f %s',presLevels(iPresLevel),'db');
    
    fprintf(fileID,' & %s & ','RMSE');
    for iMethod = 0:4
        switch iMethod
            case 0 % SpaceClimatology
                load(['./Results/CVResultsSpaceClimatology_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(MSPEAll));
            case 1 % RG
                load(['./Results/CVResultsSpaceRG_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(MSPEAll));
                ref = sqrt(MSPEAll);
            case 2 % SpaceExp
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(MSPEAll),100*(ref-sqrt(MSPEAll))/ref);
            case 3 % SpaceExpExtended
                load(['./Results/CVResultsSpaceExpExtended_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(MSPEAll),100*(ref-sqrt(MSPEAll))/ref);
            case 4 % SpaceTimeExp
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) \\\\\n',sqrt(MSPEAll),100*(ref-sqrt(MSPEAll))/ref);
        end
    end
    
    fprintf(fileID,'& %s & ','Q$_3$AE');
    for iMethod = 0:4
        switch iMethod
            case 0 % SpaceClimatology
                load(['./Results/CVResultsSpaceClimatology_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(Q3SPEAll));
            case 1 % RG
                load(['./Results/CVResultsSpaceRG_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(Q3SPEAll));
                ref = sqrt(Q3SPEAll);
            case 2 % SpaceExp
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(Q3SPEAll),100*(ref-sqrt(Q3SPEAll))/ref);
            case 3 % SpaceExpExtended
                load(['./Results/CVResultsSpaceExpExtended_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(Q3SPEAll),100*(ref-sqrt(Q3SPEAll))/ref);
            case 4 % SpaceTimeExp
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) \\\\\n',sqrt(Q3SPEAll),100*(ref-sqrt(Q3SPEAll))/ref);
        end
    end
    
    fprintf(fileID,'& %s & ','MdAE');
    for iMethod = 0:4
        switch iMethod
            case 0 % SpaceClimatology
                load(['./Results/CVResultsSpaceClimatology_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(MdSPEAll));
            case 1 % RG
                load(['./Results/CVResultsSpaceRG_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f & ',sqrt(MdSPEAll));
                ref = sqrt(MdSPEAll);
            case 2 % SpaceExp
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(MdSPEAll),100*(ref-sqrt(MdSPEAll))/ref);
            case 3 % SpaceExpExtended
                load(['./Results/CVResultsSpaceExpExtended_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) & ',sqrt(MdSPEAll),100*(ref-sqrt(MdSPEAll))/ref);
            case 4 % SpaceTimeExp
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\,\\%%) \\\\\n',sqrt(MdSPEAll),100*(ref-sqrt(MdSPEAll))/ref);
        end
    end
    
    if iPresLevel == 1 || iPresLevel == 2
        fprintf(fileID,'%s\n','\midrule');
    end
end

fclose(fileID);

%%

fileID = fopen('./Results/CVTableStudentNugget.dat','w');

CVStartYear = 2007;
CVEndYear = 2016;
month = 2;
presLevels = [10,300,1500];

for iPresLevel = 1:3
    
    fprintf(fileID,'%1.0f %s',presLevels(iPresLevel),'db');
    
    fprintf(fileID,' & %s & ','RMSE');
    for iMethod = 1:2
        switch iMethod
            case 1 % SpaceGPML
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(MSPEAll);
                load(['./Results/CVResultsSpaceGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) & ',sqrt(MSPEAll),100*(ref-sqrt(MSPEAll))/ref);
            case 2 % SpaceTimeGPML
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(MSPEAll);
                load(['./Results/CVResultsSpaceTimeGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) \\\\\n',sqrt(MSPEAll),100*(ref-sqrt(MSPEAll))/ref);
        end
    end
    
    fprintf(fileID,'& %s & ','Q$_3$AE');
    for iMethod = 1:2
        switch iMethod
            case 1 % SpaceGPML
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(Q3SPEAll);
                load(['./Results/CVResultsSpaceGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) & ',sqrt(Q3SPEAll),100*(ref-sqrt(Q3SPEAll))/ref);
            case 2 % SpaceTimeGPML
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(Q3SPEAll);
                load(['./Results/CVResultsSpaceTimeGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) \\\\\n',sqrt(Q3SPEAll),100*(ref-sqrt(Q3SPEAll))/ref);
        end
    end
    
    fprintf(fileID,'& %s & ','MdAE');
    for iMethod = 1:2
        switch iMethod
            case 1 % SpaceGPML
                load(['./Results/CVResultsSpaceExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(MdSPEAll);
                load(['./Results/CVResultsSpaceGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) & ',sqrt(MdSPEAll),100*(ref-sqrt(MdSPEAll))/ref);
            case 2 % SpaceTimeGPML
                load(['./Results/CVResultsSpaceTimeExp_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                ref = sqrt(MdSPEAll);
                load(['./Results/CVResultsSpaceTimeGPML_',num2str(presLevels(iPresLevel)),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
                fprintf(fileID,'%1.4f (%1.1f\\%%) \\\\\n',sqrt(MdSPEAll),100*(ref-sqrt(MdSPEAll))/ref);
        end
    end
    
    if iPresLevel == 1 || iPresLevel == 2
        fprintf(fileID,'%s\n','\midrule');
    end
end

fclose(fileID);