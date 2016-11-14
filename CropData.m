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

lsSave = dir(fullfile(saveDir,'*.mat'));
if ~isempty(lsSave)
    dataDir = saveDir;
end

saveName  = [timestamp,'.mat'];
savePath  = fullfile(saveDir,saveName);

% Load data
objArray = loadData(dataDir);

% Create DB file and object
DB = matfile(savePath,'Writable',true);
DB.objArray = objArray;

% Crop data
nObj = numel(objArray);
for iObj = 1:nObj
    thisObj = objArray(iObj);
    
    % Check if data was already cropped
    if ~all(thisObj.Observation)
        menuTxt = sprintf('Subject: %s, Session: %s \nappears to be cropped.\nWould you like to skip?',thisObj.ID,thisObj.Session.Name);
        opts = {'Yes, (Skip)','No, (Crop)'};
        choice = menu(menuTxt,opts);
        if choice == 1
            DB.objArray = objArray;
            continue
        end
    end
    
    % Crop the data
    thisObj = crop(thisObj);
    
    objArray(iObj) = thisObj;
    
    % Save data
    DB.objArray = objArray;
    
    if iObj ~= nObj
        menuTxt = sprintf('Cropping saved.\nWould you like to continue');
        opts = {'Yes, continue','No, exit'};
        choice = menu(menuTxt,opts);
        if choice == 2
            DB.objArray = objArray;
            return
        end
    end
end

end
