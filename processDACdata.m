close all;
clear;

oldDir = pwd;
cd('~/Argo_data/201705-ArgoData/dac/');

fileListDelayed = dir('**/D*.nc');
fileListRealTime = dir('**/R*.nc');

cd(oldDir);

fileList = [fileListDelayed; fileListRealTime];
nFile = length(fileList);

startYear = 2007;
endYear = 2016;

profPresAggr = {};
profTempAggr = {};
profPsalAggr = {};
profYearAggr = [];
profMonthAggr = [];
profLatAggr = [];
profLongAggr = [];
profJulDayAggr = [];
profFloatIDAggr = [];
profCycleNumberAggr = [];
profModeAggr = [];

progInterval = 20000;

parfor_progress(ceil(nFile/progInterval));

tic;
for iFile = 1:nFile

    fid = netcdf.open([fileList(iFile).folder,'/',fileList(iFile).name], 'nowrite');
    
    val = netcdf.inqDimID(fid,'N_PARAM');
    [~,nParam] = netcdf.inqDim(fid,val);
    if nParam < 3
        netcdf.close(fid);
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Require both temperature and salinity profile
    end

    val = netcdf.inqVarID(fid,'DATA_MODE');
    profMode = netcdf.getVar(fid,val);
    profMode = profMode(1);
    
    val = netcdf.inqVarID(fid,'LATITUDE');
    profLat = netcdf.getVar(fid,val);
    profLat = profLat(1);
    val = netcdf.inqVarID(fid,'LONGITUDE');
    profLong = netcdf.getVar(fid,val);
    profLong = profLong(1);
    val = netcdf.inqVarID(fid,'POSITION_QC');
    profPosQC = netcdf.getVar(fid,val);
    profPosQC = profPosQC(1);

    val = netcdf.inqVarID(fid,'PLATFORM_NUMBER');
    profFloatID = netcdf.getVar(fid,val);
    profFloatID = sscanf(profFloatID,'%7u');
    profFloatID = profFloatID(1);
    
    val = netcdf.inqVarID(fid,'CYCLE_NUMBER');
    profCycleNumber = netcdf.getVar(fid,val);
    profCycleNumber = profCycleNumber(1);

    val = netcdf.inqVarID(fid,'REFERENCE_DATE_TIME');
    refDateTime = netcdf.getVar(fid,val);

    refDay = datenum(sscanf(refDateTime(1:4),'%f'),sscanf(refDateTime(5:6),'%f'),sscanf(refDateTime(7:8),'%f'),0,0,0);

    val = netcdf.inqVarID(fid,'JULD');    
    profJulDay = netcdf.getVar(fid,val) + refDay;
    profJulDay = profJulDay(1);
    val = netcdf.inqVarID(fid,'JULD_QC');
    profJulDayQC = netcdf.getVar(fid,val);
    profJulDayQC = profJulDayQC(1);
    
    profTime = datevec(profJulDay);
    profYear = profTime(1);
    profMonth = profTime(2);
    
    if profYear < startYear || profYear > endYear || profCycleNumber == 0
        netcdf.close(fid);
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Profile didn't occur between 2007-2016 or it's from the launch cycle
    end

    if profMode == 'D' || profMode == 'A' % Use adjusted values, if available
            val = netcdf.inqVarID(fid,'PRES_ADJUSTED');
            profPres = netcdf.getVar(fid,val);
            profPres = double(profPres);
            profPres = profPres(:,1);
            val = netcdf.inqVarID(fid,'TEMP_ADJUSTED');
            profTemp = netcdf.getVar(fid,val);
            profTemp = double(profTemp);
            profTemp = profTemp(:,1);
            val = netcdf.inqVarID(fid,'PSAL_ADJUSTED');
            profPsal = netcdf.getVar(fid,val);
            profPsal = double(profPsal);
            profPsal = profPsal(:,1);
            val = netcdf.inqVarID(fid,'PRES_ADJUSTED_QC');
            profPresQC = netcdf.getVar(fid,val);
            profPresQC = profPresQC(:,1);
            val = netcdf.inqVarID(fid,'TEMP_ADJUSTED_QC');
            profTempQC = netcdf.getVar(fid,val);
            profTempQC = profTempQC(:,1);
            val = netcdf.inqVarID(fid,'PSAL_ADJUSTED_QC');
            profPsalQC = netcdf.getVar(fid,val);
            profPsalQC = profPsalQC(:,1);
    else % profMode == 'R'
            val = netcdf.inqVarID(fid,'PRES');
            profPres = netcdf.getVar(fid,val);
            profPres = double(profPres);
            profPres = profPres(:,1);
            val = netcdf.inqVarID(fid,'TEMP');
            profTemp = netcdf.getVar(fid,val);
            profTemp = double(profTemp);
            profTemp = profTemp(:,1);
            val = netcdf.inqVarID(fid,'PSAL');
            profPsal = netcdf.getVar(fid,val);
            profPsal = double(profPsal);
            profPsal = profPsal(:,1);
            val = netcdf.inqVarID(fid,'PRES_QC');
            profPresQC = netcdf.getVar(fid,val);
            profPresQC = profPresQC(:,1);
            val = netcdf.inqVarID(fid,'TEMP_QC');
            profTempQC = netcdf.getVar(fid,val);
            profTempQC = profTempQC(:,1);
            val = netcdf.inqVarID(fid,'PSAL_QC');
            profPsalQC = netcdf.getVar(fid,val);
            profPsalQC = profPsalQC(:,1);
    end
    
    val = netcdf.inqVarID(fid,'PRES_ADJUSTED_ERROR'); % Needed to filter out problematic APEX floats
    profPresAdjustedError = netcdf.getVar(fid,val);
    profPresAdjustedError = double(profPresAdjustedError);
    profPresAdjustedError = profPresAdjustedError(:,1);

    netcdf.close(fid);

    profPres(profPres == 99999) = NaN;
    profTemp(profTemp == 99999) = NaN;
    profPsal(profPsal == 99999) = NaN;
    profPresAdjustedError(profPresAdjustedError == 99999) = NaN;
    
    if max(diff(profPres)) > 200
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Reject profiles with large (> 200 db) pressure jumps
    end
    
    if profPres(end)-profPres(1) < 100
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Reject profiles that are shorter than 100 db
    end
    
    if sum(profPresAdjustedError >= 20) > 0
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Reject profiles from the problematic APEX floats (PRES_ADJUSTED_ERROR >= 20)
    end

    % If entry is 1, then that value is bad
    profPosQCBoolean = ~(double(profPosQC) == double('1') | double(profPosQC) == double('2'));
    profJulDayQCBoolean = ~(double(profJulDayQC) == double('1') | double(profJulDayQC) == double('2'));
    profPresQCBoolean = ~(double(profPresQC) == double('1') | double(profPresQC) == double('2') | double(profPresQC) == double(' '));
    profTempQCBoolean = ~(double(profTempQC) == double('1') | double(profTempQC) == double('2') | double(profTempQC) == double(' '));
    profPsalQCBoolean = ~(double(profPsalQC) == double('1') | double(profPsalQC) == double('2') | double(profPsalQC) == double(' '));

    % Detect empty profiles
    profPresEmpty = sum(isnan(profPres)) == size(profPres,1);
    profTempEmpty = sum(isnan(profTemp)) == size(profTemp,1);
    profPsalEmpty = sum(isnan(profPsal)) == size(profPsal,1);

    % Check that pressure and temperature/salinity profiles have same length
    profPresTempLength = (sum(~isnan(profPres)) ~= sum(~isnan(profTemp)));
    profPresPsalLength = (sum(~isnan(profPres)) ~= sum(~isnan(profPsal)));

    % Detect profiles with only one observation
    profPresSingleton = (sum(~isnan(profPres)) == 1);

    % Require a strictly increasing pressure profile
    profPresInc = sum(diff(profPres) <= 0);
    
    % Require valid position
    profInvalidPos = ~(profLat <= 90 & profLat >= -90 & profLong <= 180 & profLong >= -180);

    % If entry is >= 1, then the profile is bad (profile rejected if it contains any bad values, i.e., partially good profiles also rejected)
    badProfile = profPosQCBoolean + profJulDayQCBoolean + sum(profPresQCBoolean) + sum(profTempQCBoolean) + sum(profPsalQCBoolean) + profPresEmpty + profTempEmpty + profPsalEmpty + profPresTempLength + profPresPsalLength + profPresSingleton + profPresInc + profInvalidPos;
    badProfile = (badProfile > 0);
    
    if badProfile
        if mod(iFile,progInterval) == 0
            parfor_progress;
        end
        continue; % Reject the bad profile
    end

    % Aggregate data
    profYearAggr = [profYearAggr profYear];
    profMonthAggr = [profMonthAggr profMonth];
    profLatAggr = [profLatAggr profLat];
    profLongAggr = [profLongAggr profLong];
    profJulDayAggr = [profJulDayAggr profJulDay];
    profFloatIDAggr = [profFloatIDAggr profFloatID];
    profCycleNumberAggr = [profCycleNumberAggr profCycleNumber];
    profModeAggr = [profModeAggr profMode];

    temp = profPres;
    temp(isnan(temp)) = [];
    profPresAggr{end+1} = temp;

    temp = profTemp;
    temp(isnan(temp)) = [];
    profTempAggr{end+1} = temp;

    temp = profPsal;
    temp(isnan(temp)) = [];
    profPsalAggr{end+1} = temp;
    
    if mod(iFile,progInterval) == 0
        parfor_progress;
    end

end

parfor_progress(0);

toc;

nProf = size(profPresAggr,2);
disp(nProf);

% Convert longitude to 0-360 degrees east scale
profLongAggr = (profLongAggr < 0).*(360 + profLongAggr) + (profLongAggr >= 0).*profLongAggr;
% Convert longitude to 20-380 degrees east scale
profLongAggr = (profLongAggr < 20).*(360 + profLongAggr) + (profLongAggr >= 20).*profLongAggr;

save('./Data/Argo_data_aggr.mat','startYear','endYear','nProf','profLatAggr','profLongAggr','profYearAggr','profMonthAggr','profJulDayAggr','profFloatIDAggr','profCycleNumberAggr','profModeAggr','profPresAggr','profTempAggr','profPsalAggr','-v7.3');

% Compress to save space
cd('./Data/');
system('tar -cvzf Argo_data_aggr.tar.gz Argo_data_aggr.mat');
system('rm Argo_data_aggr.mat');
cd('..');