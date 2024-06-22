function phaseSpaceCountries()
global pp
announceFunction()


%========================================================================%
% Load data
%========================================================================%
% Load
if ~pp.HS_robustness_check
   load('./save/countryData.mat')
else
   load('./save/countryData_HS.mat')
end

% Unpack
uniqueRegionCodes = unique(countryData.regionCodes);
uniqueRegionTypes = unique(countryData.category);
%nRegions          = length(uniqueRegionCodes);
%nTypes            = length(uniqueRegionTypes);


%========================================================================%
% Plot
%========================================================================%
% Set appearance parameters
xLim     = [0 1.05];
yLim     = [-1.5 1.0];
fontSize = 16;

yearToPlot           = [2018:2018];
selectedCountries    = {
   ...%'JPN','ISL','AUS','ESP','IRL','USA','DEU','KOR','MEX','POL',...               %OECD
   'JPN','ESP','DEU',...               %OECD
   ...'LAO','SDN','MWI','TUV','ZMB','UGA','TZA','NPL','GMB','KIR','BTN','MRT',...   %developing
   'LAO','SDN','TUV','MRT',...   %developing
   'BRN','KWT','SAU',...                                                         %oil
   'BMU','AND','GIB',...                                                         %tax havens
   };

labelFontSize        = 8;
labelColor           = 'k';
xNudge               = 0.01;

markerSize           = 7;
markerLineWidth      = 1.5;

marker_oecd          = 's';
color_oecd           = MatlabColors(1);
faceColor_oecd       = color_oecd;
edgeColor_oecd       = color_oecd;

marker_developing    = 'o';
color_developing     = MatlabColors(2);
faceColor_developing = color_developing;
edgeColor_developing = color_developing;

marker_oil           = '^';
color_oil            = MatlabColors(4);
faceColor_oil        = 'w';
edgeColor_oil        = color_oil;

marker_taxhaven      = 'd';
color_taxhaven       = MatlabColors(5);
faceColor_taxhaven   = 'w';
edgeColor_taxhaven   = color_taxhaven;

% marker_tourism      = 'p';
% color_tourism       = MatlabColors(5);
% faceColor_tourism   = color_tourism;
% edgeColor_tourism   = 'w';
% 
% marker_other      = 'p';
% color_other       = 'k';
% faceColor_other   = color_other;
% edgeColor_other   = 'w';

% Setup figure
newFigure( [mfilename,'.binCounts'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.6107    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(xLim, [0 0], 'k-')

hasRightYear = ismember(countryData.years, yearToPlot);

% OECD countries
hasRightType = strcmp(countryData.category, 'oecd');
dataSubset   = countryData(hasRightYear & hasRightType,:);
h_oecd = plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_oecd, 'MarkerFaceColor',faceColor_oecd, 'MarkerEdgeColor',edgeColor_oecd, 'MarkerSize',markerSize, 'LineWidth',markerLineWidth);
%text(dataSubset.A + xNudge, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Developing countries
hasRightType = strcmp(countryData.category, 'ldc');
dataSubset   = countryData(hasRightYear & hasRightType,:);
h_developing = plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_developing, 'MarkerFaceColor',faceColor_developing, 'MarkerEdgeColor',edgeColor_developing, 'MarkerSize',markerSize, 'LineWidth',markerLineWidth);
%text(dataSubset.A + xNudge, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Oil countries
hasRightType = strcmp(countryData.category, 'resource');
dataSubset   = countryData(hasRightYear & hasRightType,:);
h_oil = plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_oil, 'MarkerFaceColor',faceColor_oil, 'MarkerEdgeColor',edgeColor_oil, 'MarkerSize',markerSize, 'LineWidth',markerLineWidth);
%text(dataSubset.A + xNudge, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Tax haven countries
hasRightType = strcmp(countryData.category, 'taxhaven');
dataSubset   = countryData(hasRightYear & hasRightType,:);
h_taxhaven = plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_taxhaven, 'MarkerFaceColor',faceColor_taxhaven, 'MarkerEdgeColor',edgeColor_taxhaven, 'MarkerSize',markerSize, 'LineWidth',markerLineWidth);
%text(dataSubset.A + xNudge, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Tourism countries
%hasRightType = strcmp(countryData.category, 'tourism');
%dataSubset   = countryData(hasRightYear & hasRightType,:);
%plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_oecd, 'MarkerFaceColor',faceColor_oecd, 'MarkerEdgeColor',edgeColor_oecd)
%text(dataSubset.A, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Other countries
%hasRightType = strcmp(countryData.category, 'other');
%dataSubset   = countryData(hasRightYear & hasRightType,:);
%plot(dataSubset.A, dataSubset.ECIstar, 'LineStyle','none', 'Marker',marker_oecd, 'MarkerFaceColor',faceColor_oecd, 'MarkerEdgeColor',edgeColor_oecd)
%text(dataSubset.A, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',labelFontSize)

% Label selected countries
isDisplayed = ismember(countryData.regionCodes, selectedCountries);
dataSubset  = countryData(hasRightYear & isDisplayed, :);   
%text(dataSubset.A + xNudge, dataSubset.ECIstar, dataSubset.regionCodes, 'Color',labelColor, 'FontSize',12);

hold off

% Legend
hLegend = legend([h_oecd, h_developing, h_taxhaven, h_oil], 'OECD','developing','tax havens','resource-rich', 'Location','SouthEast');
set(hLegend, 'Box','off', 'FontSize',fontSize)

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
%set(gca, 'XScale','log')
%set(gca, 'YScale','log')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
%set(gca, 'DataAspectRatio', [1 1 1])
%set(gca, 'XTick',[])
%set(gca, 'YTick',[])
consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',fontSize)
xlabel('Average ability coordinate A')
ylabel('Composition coordinate b (ECI*)')
%title('filler','Color','b')%, 'Visible','off')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'phaseSpaceCountries';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end




