close all;
clear;

month = 2;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

disp(presLevel);

startYear = 2007;
endYear = 2016;
localVariance = load(['./Results/localVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat']);
varGrid = localVariance.varGrid;
thetas = varGrid/1.15;
latGrid = localVariance.latGrid;
longGrid = localVariance.longGrid;

CVStartYear = 2007;
CVEndYear = 2012;

nCVYear = CVEndYear - CVStartYear + 1;
preds = cell(1,nCVYear);
predVariance = cell(1,nCVYear);

CVYears = CVStartYear:CVEndYear;

parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))

for iCVYear = 1:nCVYear
    
    disp(CVYears(iCVYear));

    S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'.mat']);

    interpLatYear = S.interpLatYear;
    interpLongYear = S.interpLongYear;
    interpResYear = S.interpResYear;
    interpFloatIDYear = S.interpFloatIDYear;

    nRes = length(interpResYear);

    predsYear = zeros(nRes,1);
    predVarianceYear = zeros(nRes,1);

    %tic;
    covObs = zeros(nRes,nRes);
    for i = 1:nRes
        for j = 1:nRes
            covObs(i,j) = spaceCovarianceRG(interpLatYear(i),interpLongYear(i),interpLatYear(j),interpLongYear(j));
        end
    end
    %toc;

    %parfor_progress(nRes);
    
    % Discard previous iterIdx, if it exists
    fileName = ['iterIdxCrossValidateLOFOSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVYears(iCVYear)),'.txt'];
    fileID = fopen(fileName,'w');
    fclose(fileID);

    %tic;
    parfor iLeaveOut = 1:nRes
    %for iLeaveOut = 1:nRes
    
        fileID = fopen(fileName,'a');
        fprintf(fileID,'%d \n',iLeaveOut);
        fclose(fileID);

        predLat = interpLatYear(iLeaveOut);
        predLong = interpLongYear(iLeaveOut);

        interpLatYearSel = interpLatYear;
        interpLongYearSel = interpLongYear;
        interpResYearSel = interpResYear;

        sameFloat = (interpFloatIDYear == interpFloatIDYear(iLeaveOut));

        interpLatYearSel(sameFloat) = [];
        interpLongYearSel(sameFloat) = [];
        interpResYearSel(sameFloat) = [];

        nResSel = length(interpResYearSel);

        covObsSel = covObs;
        covObsSel(sameFloat,:) = [];
        covObsSel(:,sameFloat) = [];
        
        % Find grid cell that is closest to the prediction point
        [~,iLat] = min(abs(predLat - latGrid(1,:)));
        [~,iLong] = min(abs(predLong - longGrid(:,1)));
        iGrid = sub2ind(size(latGrid),iLong,iLat);

        %tic;
        covGridObs = zeros(1,nResSel);
        for iRes = 1:nResSel
            covGridObs(iRes) = spaceCovarianceRG(predLat,predLong,interpLatYearSel(iRes),interpLongYearSel(iRes));
        end
        %toc;

        %tic;
        predsYear(iLeaveOut) = covGridObs*((covObsSel + 0.15*eye(nResSel))\interpResYearSel);
        %toc;
        
        %tic;
        predVarianceYear(iLeaveOut) = thetas(iGrid)*(1 + 0.15 - covGridObs*((covObsSel + 0.15*eye(nResSel))\(covGridObs')));
        %toc;
        
        %parfor_progress;

    end
    %toc;

    %parfor_progress(0);
    
    preds{iCVYear} = predsYear;
    predVariance{iCVYear} = predVarianceYear;

end

save(['./Results/CV_LOFOPredsSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat'],'preds','predVariance','CVStartYear','CVEndYear');
