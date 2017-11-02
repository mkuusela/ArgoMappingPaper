close all;
clear;

month = 2;

startYear = 2007;
endYear = 2016;
%startYear = 2010;
%endYear = 2010;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

[latGrid,longGrid] = meshgrid(linspace(-90,90,181),linspace(20,380,361));

nGrid = numel(latGrid);

%disp(nGrid);

varGrid = zeros(size(latGrid));
nResGrid = zeros(size(latGrid));

parfor_progress(nGrid);

tic;
parpool(str2num(getenv('SLURM_CPUS_ON_NODE')))
parfor iGrid = 1:nGrid
%for iGrid = 1:nGrid
    
    %disp(iGrid);
    
    %fileID = fopen('iterIdx.txt','a');
    %fprintf(fileID,'%d \n',iGrid);
    %fclose(fileID);

    predLat = latGrid(iGrid);
    predLong = longGrid(iGrid);

    windowSize = 10;

    latMin = predLat - windowSize;
    latMax = predLat + windowSize;
    longMin = predLong - windowSize;
    longMax = predLong + windowSize;

    nYear = endYear - startYear + 1;

    interpLatAggr = cell(1,nYear);
    interpLongAggr = cell(1,nYear);
    interpResAggr = cell(1,nYear);

    for iYear = startYear:endYear

        S = load(['./Results/residualsJohn_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(iYear),'.mat']);
        
        interpLatYear = S.interpLatYear;
        interpLongYear = S.interpLongYear;
        interpResYear = S.interpResYear;

        idx = find(interpLatYear > latMin & interpLatYear < latMax & interpLongYear > longMin & interpLongYear < longMax);

        interpLatAggr{iYear-startYear+1} = interpLatYear(idx)';
        interpLongAggr{iYear-startYear+1} = interpLongYear(idx)';
        interpResAggr{iYear-startYear+1} = interpResYear(idx);

    end
    
    nResGrid(iGrid) = sum(cellfun(@length,interpResAggr));
    
    if nResGrid(iGrid) == 0 % No observations in the window
        varGrid(iGrid) = NaN;
        
        parfor_progress;
        
        continue;
    end
    
    varGrid(iGrid) = var(cell2mat(interpResAggr'));
    
    parfor_progress;
    
end
toc;

parfor_progress(0);

save(['./Results/localVariance_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(startYear),'_',num2str(endYear),'.mat'],'latGrid','longGrid','varGrid','nResGrid');
