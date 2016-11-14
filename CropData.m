function CropData

% Reset MATLAB
close all
clear
clc

% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
d12packDir      = fullfile(githubDir,'d12pack');
addpath(d12packDir);

% Map paths
timestamp = datestr(now,'yyyy-mm-dd_HHMM');

projectDir = '\\ROOT\projects\NIH-Light-Mask\Auckland';
dataDir = fullfile(projectDir,'converted_data');
saveDir = fullfile(projectDir,'cropped_data');

saveName  = [timestamp,'.mat'];
savePath  = fullfile(saveDir,saveName);

% Load data
objArray = loadData(dataDir);

% Create DB file and object
DB = matfile(savePath,'Writable',true);
DB.objArray = objArray;

% Crop data
for iObj = 1:numel(objArray)
    thisObj = objArray(iObj);
    
    % Crop the data
    thisObj = crop(thisObj);
    
    objArray(iObj) = thisObj;
    
    % Save data
    DB.objArray = objArray;
end

end
