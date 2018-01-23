fclose('all');
close all
clear
clc

h = waitbar(0,'Please wait loading data...');

objArray = loadData;

nObj = numel(objArray);

cellTemp = cell(nObj,1);
nanTemp  = nan(nObj,1);
varNames = {'ID','Light','Session','PhasorMagnitude','PhasorAngle'};
T = table(cellTemp,cellTemp,cellTemp,nanTemp,nanTemp,'VariableNames',varNames);

waitbar(0,h,'Please wait computing phasors...')
for iObj = 1:nObj
    T.ID{iObj}      = objArray(iObj).ID;
    T.Light{iObj}   = objArray(iObj).Session.Condition;
    T.Session{iObj} = objArray(iObj).Session.Name;
    
    thisPhasor = objArray(iObj).Phasor;
    if ~isempty(thisPhasor.Magnitude)
        T.PhasorMagnitude(iObj) = thisPhasor.Magnitude;
        T.PhasorAngle(iObj)     = thisPhasor.Angle.hours;
    end
    waitbar(iObj/nObj,h)
end

close(h)

% Remove excluded subjects
T2 = T;
excludeID = {'Pt02', 'Pt06', 'Pt09', 'Pt11', 'Pt24', 'Pt26', 'Pt27'};
excludeIdx = ismember(T2.ID,excludeID);
T2(excludeIdx,:) = [];

% Sort data
% idxPre  = strcmp(T2.Session,'pre');
% idxPost = strcmp(T2.Session,'post');
% idxPlacebo = strcmp(T2.Light,'placebo (red)');
% idxActive = strcmp(T2.Light,'active (blue)');
% 
% placebo_pre_ID  = T2.ID(idxPre&idxPlacebo);
% placebo_post_ID = T2.ID(idxPost&idxPlacebo);
% active_pre_ID   = T2.ID(idxPre&idxActive);
% active_post_ID  = T2.ID(idxPost&idxActive);
% 
% placebo_pre_magnitude  = T2.PhasorMagnitude(idxPre&idxPlacebo);
% placebo_post_magnitude = T2.PhasorMagnitude(idxPost&idxPlacebo);
% active_pre_magnitude   = T2.PhasorMagnitude(idxPre&idxActive);
% active_post_magnitude  = T2.PhasorMagnitude(idxPost&idxActive);
% 
% placebo_pre_angle  = T2.PhasorAngle(idxPre&idxPlacebo);
% placebo_post_angle = T2.PhasorAngle(idxPost&idxPlacebo);
% active_pre_angle   = T2.PhasorAngle(idxPre&idxActive);
% active_post_angle  = T2.PhasorAngle(idxPost&idxActive);


[p,tbl,stats,terms] = anovan(T2.PhasorMagnitude,{T2.Session T2.Light},'model',2,'varnames',{'time','light'});
xlswrite('tbl.xlsx',tbl)
[p2,tbl2,stats2,terms2] = anovan(T2.PhasorAngle,{T2.Session T2.Light},'model',2,'varnames',{'time','light'});
xlswrite('tbl2.xlsx',tbl2)