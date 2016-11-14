function [T,U] = ReadLog(filePath)
%READLOG Read and convert Daysimeter usage log from Excel file

opts = detectImportOptions(filePath);

T = readtable(filePath,opts);

% Remove empty rows
idxEmpty = cellfun(@isempty,T.subject);
T(idxEmpty,:) = [];

% Set time zones
T.bedTime.TimeZone = 'Pacific/Auckland';
T.riseTime.TimeZone = 'Pacific/Auckland';
T.dateOn.TimeZone = 'Pacific/Auckland';
T.dateOff.TimeZone = 'Pacific/Auckland';

unqID    = unique(T.subject);
nID      = numel(unqID);
natTemp  = NaT(nID,1);
natTemp.TimeZone = 'Pacific/Auckland';
nanTemp  = NaN(nID,1);
preCell  = repmat({'pre'},nID,1);
postCell = repmat({'post'},nID,1);
varNames = {'ID','Session','SerialNumber','FirstOn','LastOff'};
pre      = table(unqID,preCell,nanTemp,natTemp,natTemp,'VariableNames',varNames);
post     = table(unqID,postCell,nanTemp,natTemp,natTemp,'VariableNames',varNames);

idxPre   = strcmp(T.condition, 'pre');
idxPost  = strcmp(T.condition,'post');


for iID = 1:nID
    idxID  = strcmp(T.subject,unqID{iID});
    
    preOn   = T.dateOn(idxID&idxPre);
    preOff  = T.dateOff(idxID&idxPre);
    
    postOn  = T.dateOn(idxID&idxPost);
    postOff = T.dateOff(idxID&idxPost);
    
    
    pre.SerialNumber(iID) = mode(T.Daysimeter(idxID&idxPre));
    pre.FirstOn(iID)  = min(preOn);
    pre.LastOff(iID)  = max(preOff);
    
    post.SerialNumber(iID) = mode(T.Daysimeter(idxID&idxPost));
    post.FirstOn(iID) = min(postOn);
    post.LastOff(iID) = max(postOff);
end

U = vertcat(pre,post);

end

