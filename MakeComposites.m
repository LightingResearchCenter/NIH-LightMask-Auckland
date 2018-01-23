% Reset matlab
close all
clear
clc

h = waitbar(0,'Please wait generating composite reports...');

projectDir = '\\ROOT\projects\NIH-Light-Mask\Auckland';
dataDir = fullfile(projectDir,'cropped_data');
exportDir = fullfile(projectDir,'composites');

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
    
    d = d12pack.composite(thisObj,titleText);
    
    d.Title = titleText;
    
    fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'.pdf'];
    filePath = fullfile(exportDir,fileName);
    saveas(d.Figure,filePath);
    close(d.Figure);
    
    waitbar(iObj/n,h)
end

close(h)
