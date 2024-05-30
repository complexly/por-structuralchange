% Main file for paper.  Everything up to "ANALYSES" is the common stem, and
% then what follows are individual analyses that can be switched on or off.
clear
addpath('../data')
addpath('./save')
addpath('./analyses')
addpath('./tools')
addpath('./tools/stochastic')
addpath('./tools/DMD_ROM')
% addpathTree('~/Documents/Work/Resources/Code')
addpathTree('~/Documents/Work/Projects/Code/matlab')
global pp ap

% Processing parameters
%pp.readData            = 'read';       %read, load, use
pp.outputFolder         = './output';
pp.saveFigures          = false;
pp.HS_robustness_check  = false;
ap.fontSize             = 16;

% Setup output file
outputFile = fullfile(pp.outputFolder,'Output.txt');
delete( outputFile )
diary(  outputFile )

% Report program start
dispc('=====================================================================')
dispc('RUNNING MAIN.M...')
dispc('=====================================================================')
tic

% Create countryData table and save to .mat file
if false; preprocessCountryData(); end


% Main (+ some SI)
if false; compareComplexityMetrics(); end

if false; phaseSpaceCountries(); end
if false; phaseSpaceHeatMaps(); end
if false; phaseSpaceMovement(); end
if false; phaseSpacePathways(); end

if false; ECI_v_ECIstar(); end

% Methods
if false; analyzeRCA_distribution(); end

% SI
if false; eigenvalueSpectrum(); end
if false; correlationTimeSeries(); end
if false; phasePortrait(); end

% Main (time-consuming)
if false; visualizeProductSpaceGuide2(); end
if false; visualizeProductSpace(); end
if false; visualizeProductSpaceHighlight(); end
if false; visualizeProductSpaceHighlightFirstEV(); end


toc
diary off
dispc( [newline,newline,newline] )