function initializeProjectPaths()

%% Current MATLAB Folder

currentFolder = fileparts(mfilename('fullpath'));

%% Project Root

projectRoot = fileparts(currentFolder);

%% Lesson Functions

lessonFunctions = fullfile(pwd,'Functions');

if isfolder(lessonFunctions)

    addpath(lessonFunctions);

end

%% Common

commonFolder = fullfile(projectRoot,'Common');

if isfolder(commonFolder)

    addpath(genpath(commonFolder));

end

end