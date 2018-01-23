% Reset matlab
close all
clear
clc

h = waitbar(0,'Please wait generating Daysigrams...');

projectDir = '\\ROOT\projects\NIH-Light-Mask\Auckland';
dataDir = fullfile(projectDir,'cropped_data');
exportDir = fullfile(projectDir,'daysigrams');

% Load data
data = loadData(dataDir);

n  = numel(data);

timestamp = upper(datestr(now,'mmmdd'));

for iObj = 1:n
    thisObj = data(iObj);
    
    if isempty(thisObj.Time)
        continue
    end
    
    titleText = {'NIH Light Mask - Auckland, NZ';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
    d = d12pack.daysigram(thisObj,titleText);
    
    for iFile = 1:numel(d)
        d(iFile).Title = titleText;
        
        fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'_p',num2str(iFile),'.pdf'];
        filePath = fullfile(exportDir,fileName);
        saveas(d(iFile).Figure,filePath);
        close(d(iFile).Figure);
        
    end
    
    waitbar(iObj/n,h)
end

close(h)
