% Main file for paper.  Everything up to "ANALYSES" is the common stem, and
% then what follows are individual analyses that can be switched on or off.
clear
addpath('../python/data')
addpath('./save')
addpath('./analyses')
addpath('./tools')
addpath('./tools/SubAxis')

% Processing parameters
global pp
pp.dataFolder           = '../python/data/';
pp.outputFolder         = './output';
pp.saveFigures          = false;
pp.HS_robustness_check  = false;
pp.fontSize             = 16;

% Setup output file
outputFile = fullfile(pp.outputFolder,'Output.txt');
delete( outputFile )
diary(  outputFile )

% Report program start
disp('=====================================================================')
disp('RUNNING MAIN.M...')
disp('=====================================================================')
tic

% Create countryData table and save to .mat file
if true; preprocessCountryData(); end


% Main (+ some SI)
if true; compareComplexityMetrics(); end

if true; phaseSpaceCountries(); end
if true; phaseSpaceHeatMaps(); end
if true; phaseSpaceMovement(); end
if true; phaseSpacePathways(); end

if true; ECI_v_ECIstar(); end

% Methods
if true; analyzeRCA_distribution(); end

% SI
if true; eigenvalueSpectrum(); end
if true; correlationTimeSeries(); end
if true; phasePortrait(); end

% Main network visualizations (these are more time-consuming)
if true; visualizeProductSpaceGuide2(); end
if true; visualizeProductSpace(); end
if true; visualizeProductSpaceHighlight(); end
if true; visualizeProductSpaceHighlightFirstEV(); end


toc % ~130 sec
diary off
disp( [newline,newline,newline] )