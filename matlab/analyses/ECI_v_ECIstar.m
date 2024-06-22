function ECI_v_ECIstar()
% Plots the data.

global pp
announceFunction()

%========================================================================%
% Load data
%========================================================================%
% Load data
load('./save/countryData.mat')
ECI              = countryData.ECI;
ECIstar          = countryData.ECIstar;

%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
xLim             = [-0.15 0.15001];
yLim             = [-2 2];
marker           = 'o';
markerSize       = 14;
markerColor      = MatlabColors(1);
markerFaceColor  = markerColor;
markerEdgeColor  = markerColor;
markerFaceAlpha  = 0.3;
markerEdgeAlpha  = 0;

fontSize        = 16;

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   560])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(xLim, [0 0], 'k-')
plot([0 0], yLim, 'k-')
scatter(ECI, ECIstar, 'SizeData',markerSize, 'CData',markerColor, 'MarkerFaceColor',markerFaceColor, 'MarkerEdgeColor',markerEdgeColor, 'MarkerFaceAlpha',markerFaceAlpha, 'MarkerEdgeAlpha',markerEdgeAlpha, 'Marker',marker)
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'FontSize',fontSize)
xlabel('ECI')
ylabel('Composition coordinate b (ECI*)')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = mfilename;
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end