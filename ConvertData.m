function ConvertData

clear
clc

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack')

rootDir = '\\root\projects';
calPath = fullfile(rootDir,'DaysimeterAndDimesimeterReferenceFiles',...
    'recalibration2016','calibration_log.csv');

projectDir = '\\ROOT\projects\NIH-Light-Mask\Auckland';
dataDir   = fullfile(projectDir,'raw_files');
indexPath = fullfile(projectDir,'index.xlsx');

timestamp = datestr(now,'yyyy-mm-dd_HHMM');
dbName  = [timestamp,'.mat'];
dbPath  = fullfile(projectDir,'converted_data',dbName);

datalogLs = dir(fullfile(dataDir,'*data.txt'));
datalogPaths = fullfile(dataDir,{datalogLs.name}');
loginfoPaths = regexprep(datalogPaths,'data\.txt','log.txt');

[T,U] = ReadLog(indexPath);

nFile = numel(datalogPaths);

for iFile = nFile:-1:1
    obj = d12pack.HumanData;
    
    obj.CalibrationPath = calPath;
    obj.RatioMethod     = 'normal';
    obj.TimeZoneLaunch	= 'Pacific/Auckland';
    obj.TimeZoneDeploy	= 'Pacific/Auckland';
    
    % Import the original data
    obj.log_info = obj.readloginfo(loginfoPaths{iFile});
    obj.data_log = obj.readdatalog(datalogPaths{iFile});
    
    idxSN = obj.SerialNumber == U.SerialNumber;
    
    if ~any(idxSN)
        warning('Log entry for serial number: %d, not found',obj.SerialNumber)
        continue
    end
    
    U2 = U(idxSN,:);
    
    func = @(t1,t2) sum(isbetween(obj.Time,t1,t2));
    countBetween = arrayfun(func,U2.FirstOn,U2.LastOff);
    [~,idxBetween] = max(countBetween);
    
    if ~any(idxBetween)
        warning('No overlapping times found')
        continue
    end
    
    U3 = U2(idxBetween,:);
    
    % Add Session
    obj.Session = struct('Name',U3.Session{1});
    
    % Add ID
    obj.ID = U3.ID{1};
    
    % Find bed log
    idxID = strcmp(T.subject,obj.ID);
    idxSession = strcmp(T.condition,obj.Session.Name);
    T2 = T(idxID&idxSession,:);
    
    idxNaT = isnat(T2.bedTime) | isnat(T2.riseTime);
    T3 = T2(~idxNaT,:);
    
    nBed = height(T3);
    
    if nBed >= 1
        % Add bed log
        tempBedLog = d12pack.BedLogData;
        for iBed = nBed:-1:1
            tempBedLog(iBed,1).BedTime  = T3.bedTime(iBed);
            tempBedLog(iBed,1).RiseTime = T3.riseTime(iBed);
        end
        obj.BedLog = tempBedLog;
    else
        warning('No matching bed logs found')
        disp(T2)
    end
    
    % Add object to array of objects
    objArray(iFile,1) = obj;
    
end

% Keep only unique data sets
ID = {objArray(:).ID}';
session = [objArray(:).Session]';
sessionName = {session(:).Name}';
idSession = [char(ID),char(sessionName)];
[unq,idx] = unique(idSession,'rows');
objArray = objArray(idx,1);

% Save converted data to file
save(dbPath,'objArray');

end