function phaseSpaceHeatMaps()
global pp hdiversity
announceFunction()

%========================================================================%
% Load data
%========================================================================%
% Load
if ~pp.HS_robustness_check
   load('./save/countryData.mat')
   diversity_countours_file = './save/logDiversityFit.mat';
   gdp_contours_files = './save/loggdpFit.mat';

   % Notes on slist:
   %   - These numbers give the fractional distance [0 to 1] along the full
   %     length of a contour at which to place a label
   %   - It also controls whether the label appears at all (whether it is nan or
   %     not)
   %   - The order of the numbers is in the list is the order of the countours
   %     returned by the contour function. sList is not in general the same
   %     length as the levelList above because country(...) may return
   %     multiple contour segments per level. You need to selectively skip
   %     over some silly segments through trial-and-error to determine which
   %     contours to label and what a good s-value is.
   sList_GDP   = [nan nan 0.65 0.635 0.62 0.615 0.61 0.5 0.60 0.61];
   sList_diversity   = [nan nan 0.45 0.45 0.45 0.45 0.44];
else
   load('./save/countryData_HS.mat')
   diversity_countours_file = './save/logDiversityFit_HS.mat';
   gdp_contours_files = './save/loggdpFit_HS.mat';

   sList_GDP   = [nan 0.61 0.66 0.65 0.625 nan 0.64 nan nan nan 0.775 nan 0.735];
   sList_diversity   = [nan 0.285 nan 0.55 0.55 nan 0.55 0.6];
end

% Unpack
ECIdata          = countryData.ECIstar;
Adata            = countryData.A;
logDiversityData = log10(countryData.diversity);
logGDPData       = log10(countryData.GDPpc);
giniData         = countryData.gini;
shannonData      = countryData.shannon;
hhiData          = countryData.hhi;

overrideWithConventionalECI = false;
if overrideWithConventionalECI
   ECIdata      = countryData.ECI;

   % Rescale the conventional ECI to avoid having to redo the axes on the
   % plots
   max_ECIstar  = max( countryData.ECIstar );
   max_ECI      = max( countryData.ECI );
   ECIdata      = ECIdata * (max_ECIstar / max_ECI) * 0.8;
end

overrideWithDiversity = false;
if overrideWithDiversity
   Adata = log10(countryData.diversity);
   
   % Rescale log diversity to avoid having to redo the axes on the plots
   max_diversity  = max( log10(countryData.diversity) );
   Adata          = Adata / max_diversity;
end




%========================================================================%
% Compute heat maps
%========================================================================%
% Bin data
nbins_Z     = 50;
nbins_ECI   = 50;
Z_edges     = linspace(0,1,nbins_Z+1)';
ECI_edges   = linspace(min(ECIdata), max(ECIdata), nbins_ECI+1)';
Z_binLocs   = discretize(Adata, Z_edges);
ECI_binLocs = discretize(ECIdata, ECI_edges);
Zcenters    = getcenters(Z_edges);
ECIcenters  = getcenters(ECI_edges);

% Get bin counts
binCounts = hist3([Adata ECIdata], {Z_edges, ECI_edges});
binCounts = binCounts(1:end-1,1:end-1);

% Get the mean GDP in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanGDP(i_bin) = nanmean( logGDPData(mask) );
end
meanGDP = reshape(meanGDP, [nbins_Z nbins_ECI]);
%meanGDP( binCounts <= 6 ) = nan;

% Get the mean diversity in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanDiversity(i_bin) = nanmean( logDiversityData(mask) );
end
meanDiversity = reshape(meanDiversity, [nbins_Z nbins_ECI]);

% Get the mean gini coefficient in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanGini(i_bin) = nanmean( giniData(mask) );
end
meanGini = reshape(meanGini, [nbins_Z nbins_ECI]);

% Get the mean hhi coefficient in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanHHI(i_bin) = nanmean( hhiData(mask) );
end
meanHHI = reshape(meanHHI, [nbins_Z nbins_ECI]);

% Get the mean shannon entropy in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanShannon(i_bin) = nanmean( shannonData(mask) );
end
meanShannon = reshape(meanShannon, [nbins_Z nbins_ECI]);

% Get the mean Hill number in each bin
linearIndex = sub2ind([nbins_Z nbins_ECI], Z_binLocs, ECI_binLocs);
for i_bin = 1:nbins_Z*nbins_ECI
   mask = (linearIndex == i_bin);
   meanHillNumber(i_bin) = nanmean( exp(shannonData(mask)) );
end
meanHillNumber = reshape(meanHillNumber, [nbins_Z nbins_ECI]);




%========================================================================%
% Define the high-density band of the data
%========================================================================%
% Define the bounds and create inputs for the fill function
slope        = 1.5 / 1;
x0_upper     = 0;
y0_upper     = -0.6;

x0_lower     = 0;
y0_lower     = -1.5;

X_upperBound = [-0.1 1.1];
X_lowerBound = X_upperBound;

Y_upperBound = y0_upper + slope * (X_upperBound - x0_upper);
Y_lowerBound = y0_lower + slope * (X_lowerBound - x0_lower);

XV = [X_lowerBound X_upperBound(end:-1:1)];
YV = [Y_lowerBound Y_upperBound(end:-1:1)];

isInside = inpolygon(Adata, ECIdata, XV, YV);
nInside  = sum(isInside);
nData    = length(Adata);
fractionInside = nInside / nData
fractionString = num2str( round(fractionInside*100) );







%========================================================================%
% Find contours of diversity and GDP per capita
%========================================================================%
% Find approximate contours of diversity in the data
fitDiversity = false;
if fitDiversity
   % Non-parametrically fit data to a surface
   mask    = (logDiversityData ~= 0);
   X       = [Adata(mask) ECIdata(mask)];
   Y       = logDiversityData(mask);
   
   fitType = 'lowess';
   fitObj  = fit(X, Y, fitType);
   
   % Get the contours of the surface
   xRange            = linspace(0, 1.2, 100);
   yRange            = linspace(min(ECIdata), -min(ECIdata), 100);
   [Xsample,Ysample] = meshgrid(xRange, yRange);
   logDiversityHat   = feval(fitObj, Xsample, Ysample);
   
   save(diversity_countours_file,'logDiversityHat','Xsample','Ysample','fitObj')
else
   load(diversity_countours_file)
end

% Find approximate contours of GDP per capita in the data
fitGDP = false;
if fitGDP
   % Non-parametrically fit data to a surface
   mask    = ~isnan(logGDPData);
   X       = [Adata(mask) ECIdata(mask)];
   Y       = logGDPData(mask);
   
   fitType = 'lowess';
   fitObj  = fit(X, Y, fitType);
   
   % Get the contours of the surface
   xRange      = linspace(0, 1.2, 100);
   yRange      = linspace(min(ECIdata), -min(ECIdata), 100);
   [Xgdp,Ygdp] = meshgrid(xRange, yRange);
   logGDPHat   = feval(fitObj, Xgdp, Ygdp);
   
   save(gdp_contours_files,'logGDPHat','Xgdp','Ygdp','fitObj')
else
   load(gdp_contours_files)
end



%========================================================================%
% Overall appearance parameters
%========================================================================%
xLim     = [0 1.05];
yLim     = [-1.5 1.0];  %[min(ECIdata) -min(ECIdata)];
fontSize = 16;


%========================================================================%
% Plot bin counts
%========================================================================%
% Color map parameters
nColors    = 100;
firstColor = [1 1 1];
lastColor  = MatlabColors(4);
cmap       = makeColorMap(nColors, firstColor, lastColor);

bandColor     = 1*[1 1 1];
bandAlpha     = 0.15;
bandLineStyle = ':';
bandLineColor = 0.6*[1 1 1];
bandLineWidth = 2;

% Setup figure
newFigure( [mfilename,'.binCounts'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
h_pcolor = pcolor(Zcenters, ECIcenters, binCounts');
%plot(X_indicator(1),   Y_indicator(1), 'ko', 'MarkerFaceColor','k')
%plot(X_indicator(end), Y_indicator(end), 'ko', 'MarkerFaceColor','k')
%plot(X_upperBound,      Y_upperBound, 'k', 'LineWidth',2)
%plot(X_lowerBound,      Y_lowerBound, 'k', 'LineWidth',2)
fill(XV, YV, bandColor, 'FaceAlpha',bandAlpha, 'LineStyle',bandLineStyle, 'EdgeColor',bandLineColor, 'LineWidth',bandLineWidth)
set(h_pcolor, 'LineStyle','none')
plot(xLim, [0 0], 'k--')
hold off

% Show double arrow and label
annotation(gcf,'doublearrow',[0.733928571428571 0.733928571428571],...
   [0.81952380952381 0.561904761904763]);
annotation(gcf,'textbox',...
   [0.60 0.71 0.133035714285714 0.0535714285714286],...
   'String',[fractionString,'% of data'], 'HorizontalAlignment','right', 'LineStyle','none', 'FontSize',fontSize);


% Set colors
colormap(cmap)

% Make colorbar
colorbar()

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
title('Country-year observations','FontWeight','normal')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'binCountHeatMap';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end



%========================================================================%
% Plot GDP per capita
%========================================================================%
% Color map parameters
nColors          = 100;
firstColor       = [1 1 1];
lastColor        = MatlabColors(7);
%cmap       = makeColorMap(nColors, firstColor, lastColor);
cmap             = 'parula';
% levelList        = log10([300 1000 2000 3000 6000 10000 20000 30000]);
levelList        = log10([300 1000 2000 3000 6000 10000 20000 30000]);
contourColor     = 'w';
contourLineWidth = 0.75;

% Setup figure
newFigure( [mfilename,'.GDPpercapita'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
h_pcolor = pcolor(Zcenters, ECIcenters, meanGDP');
set(h_pcolor, 'LineStyle','none')
plot(xLim, [0 0], 'k--')
[contourMatrix,hContour] = contour(Xgdp,Ygdp,logGDPHat, 'LineWidth',contourLineWidth, 'LineColor',contourColor, 'LevelList',levelList);
hold off

% Contour labels
hLabels = drawContourLabels(contourMatrix,sList_GDP);
for iLabel = 1:length(hLabels)
   set(hLabels(iLabel), 'BackgroundColor','none')
   contourLevel = str2num( get(hLabels(iLabel), 'String') );
   set(hLabels(iLabel), 'String',num2str( round(10.^contourLevel,-1) ))
end

% Set colors
colormap(cmap)
%colorDataLimits = [-10 140];

% Make colorbar
hColorBar = colorbar();
set(hColorBar, 'YTick',log10([300 1000 3000 10000 30000]))
set(hColorBar, 'YTickLabel',{'$300' '$1000' '$3000' '$10000' '$30000'})

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
title('GDP per capita (2010 US$ PPP)','FontWeight','normal')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'gdpHeatMap';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end




%========================================================================%
% Plot diversity
%========================================================================%
% Color map parameters
nColors    = 100;
firstColor = [1 1 1];
lastColor  = [40 84 130]/255;%MatlabColors(7);
%cmap       = makeColorMap(nColors, firstColor, lastColor);
%cmap       = diversityColorMap();
cmap       = 'parula';
colorDataLimits = [0 max(meanDiversity(:))];
%contourLevelStep = 10;
levelList        = log10([3 6 10 20 30 60 100]);
contourColor  = 'w';


% Setup figure
hdiversity = newFigure( [mfilename,'.diversity'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
h_pcolor = pcolor(Zcenters, ECIcenters, meanDiversity');
set(h_pcolor, 'LineStyle','none')
plot(xLim, [0 0], 'k--')
[contourMatrix,hContour] = contour(Xsample,Ysample,logDiversityHat, 'LineWidth',contourLineWidth, 'LineColor',contourColor, 'LevelList',levelList);
hold off

% Contour labels
hLabels = drawContourLabels(contourMatrix,sList_diversity);
for iLabel = 1:length(hLabels)
   set(hLabels(iLabel), 'BackgroundColor','none')
   contourLevel = str2num( get(hLabels(iLabel), 'String') );
   set(hLabels(iLabel), 'String',num2str( round(10.^contourLevel) ))
end

% Set colors
colormap(cmap)
set(gca, 'CLim',colorDataLimits)

% Make colorbar
hColorBar = colorbar();
set(hColorBar, 'YTick',log10([1 3 10 30 100]))
set(hColorBar, 'YTickLabel',[1 3 10 30 100])

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
title('Diversity','FontWeight','normal')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'diversityHeatMap';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end




%========================================================================%
% Plot gini
%========================================================================%
% Color map parameters
nColors    = 100;
firstColor = [1 1 1];
lastColor  = [40 84 130]/255;%MatlabColors(7);
%cmap       = makeColorMap(nColors, firstColor, lastColor);
%cmap       = diversityColorMap();
cmap       = 'parula';
colorDataLimits = [0 max(meanDiversity(:))];
contourLineWidth     = 0.75;
%contourLevelStep = 10;
levelList        = log10([3 6 10 20 30 60 100]);
contourColor  = 'w';


% Setup figure
newFigure( [mfilename,'.gini'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
h_pcolor = pcolor(Zcenters, ECIcenters, log(1-meanGini)');
set(h_pcolor, 'LineStyle','none')
plot(xLim, [0 0], 'k--')
%[contourMatrix,hContour] = contour(Xsample,Ysample,logDiversityHat, 'LineWidth',isolineWidth, 'LineColor',contourColor, 'LevelList',levelList);
hold off

% Contour labels
% sList   = [nan nan 0.45 0.45 0.45 0.45 0.44];
% hLabels = drawContourLabels(contourMatrix,sList);
% for iLabel = 1:length(hLabels)
%    set(hLabels(iLabel), 'BackgroundColor','none')
%    contourLevel = str2num( get(hLabels(iLabel), 'String') );
%    set(hLabels(iLabel), 'String',num2str( round(10.^contourLevel) ))
% end

% Set colors
%colormap(cmap)
%set(gca, 'CLim',colorDataLimits)

% Make colorbar
hColorBar = colorbar();
%set(hColorBar, 'YTick',log10([1 3 10 30 100]))
%set(hColorBar, 'YTickLabel',[1 3 10 30 100])

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
title('Other diversities: 1-Gini coeff.','FontWeight','normal')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'giniHeatMap';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end




