function phaseSpaceMovement()
global pp hdiversity
announceFunction()


%========================================================================%
% Load data
%========================================================================%
% Load
% if ~pp.HS_robustness_check
if true
   load('./save/countryData.mat')
   Delta_t     = 20;   %amount of time averaging to do

   % Important: For the robustness check, impose a minimum year on the
   % -SITC- data to get an apples-to-apples comparison between SITC and HS
   % data (loaded in the other branch of this if statement).
   generate_SITC_robustness_comparison = false;
   if generate_SITC_robustness_comparison
      minYear     = 1995;
      countryData = countryData(countryData.years >= 1995, :);
   end
else
   load('./save/countryData_HS.mat')
   Delta_t     = 20;   %amount of time averaging to do
end



%========================================================================%
% Set analysis parameters
%========================================================================%
nbins_A     = 10; %10
nbins_ECI   = 12; %12
minBinCount = 0;  %6
minAveSpeed = 0.07;


%========================================================================%
% Compute future velocity of each region-year observation
%========================================================================%
uniqueRegionCodes = unique(countryData.regionCodes);
nRegions          = length(uniqueRegionCodes);

% Create lists for starting points and changes over next Delta_t years
A_list               = [];
ECI_list             = [];
dA_list              = [];
dECI_list            = [];
for c = 1:nRegions
   % For this region obtain the time series of Z and ECI
   thisRegion       = uniqueRegionCodes{c};
   tableSubset      = countryData( strcmp(countryData.regionCodes,thisRegion), : );
   tableSubset      = sortrows(tableSubset, 'years');
   AtimeSeries_c    = tableSubset.A;
   ECItimeSeries_c  = tableSubset.ECIstar;
   
   % Obtain the changes in these time series over next Delta_t years
   AtimeSeries1_c   = AtimeSeries_c(1 : end-Delta_t);
   AtimeSeries2_c   = AtimeSeries_c(1+Delta_t : end);
   ECItimeSeries1_c = ECItimeSeries_c(1 : end-Delta_t);
   ECItimeSeries2_c = ECItimeSeries_c(1+Delta_t : end);
   dA_c             = AtimeSeries2_c   - AtimeSeries1_c;
   dECI_c           = ECItimeSeries2_c - ECItimeSeries1_c;
   
   % Record starting points and changes
   A_list           = [A_list;    AtimeSeries1_c];
   ECI_list         = [ECI_list;  ECItimeSeries1_c];
   dA_list          = [dA_list;   dA_c];
   dECI_list        = [dECI_list; dECI_c];
end


%========================================================================%
% Compute average future velocity in each (A,ECI) bin
%========================================================================%
% Bin observations in (A,ECI) bins
A_edges     = linspace(0,1,nbins_A+1)';
ECI_edges   = linspace(-1.6, 1.0, nbins_ECI+1)';
A_binLocs   = discretize(A_list, A_edges);
ECI_binLocs = discretize(ECI_list, ECI_edges);
Acenters    = getcenters(A_edges);
ECIcenters  = getcenters(ECI_edges);

% Compute the mean velocity in each bin
linearIndex = sub2ind([nbins_A nbins_ECI], A_binLocs, ECI_binLocs);
mean_dA     = zeros(nbins_A, nbins_ECI);
mean_dECI   = zeros(nbins_A, nbins_ECI);
for i_bin = 1:nbins_A*nbins_ECI
   mask             = (linearIndex == i_bin);
   mean_dA(i_bin)   = nanmean( dA_list(mask)   );
   mean_dECI(i_bin) = nanmean( dECI_list(mask) );
end
mean_dA   = reshape(mean_dA,   [nbins_A nbins_ECI]);
mean_dECI = reshape(mean_dECI, [nbins_A nbins_ECI]);

% Filter bins with small bin counts
binCounts = hist3([A_list ECI_list], {A_edges, ECI_edges});
binCounts = binCounts(1:end-1,1:end-1);
mean_dA(binCounts <= minBinCount)   = nan;
mean_dECI(binCounts <= minBinCount) = nan;



%========================================================================%
% Identify (A,ECI) bins that are low-speed and/or uncertain velocity
%========================================================================%
aveSpeed        = sqrt(mean_dA.^2 + mean_dECI.^2);
belowSpeedMin   = (aveSpeed < minAveSpeed);
[Ibelow,Jbelow] = find(belowSpeedMin);

% Collect locations of bins that are below the min speed
A_below   = Acenters(Ibelow);
ECI_below = ECIcenters(Jbelow);

% Get a convex hull around these points
pointIndices = convhull(A_below, ECI_below);

%========================================================================%
% Define three regions
%========================================================================%
Xregion1 = [ 0    1.1 1.1  0.4  0  ];
Yregion1 = [-1.5 -1.5 0    0   -0.6];

Xregion2 = [0.4 1.1 1.1 0.4];
Yregion2 = [0   0   1   1  ];

Xregion3 = [ 0   0.4 0.4 0];
Yregion3 = [-0.6 0   1   1];



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


%========================================================================%
% Compute diversity and GDP like Imbs and Wacziarg
%========================================================================%
if false
   % Bin the GDP data
   nBins = 50;
   [binIndices,binEdges] = discretize(log10(countryData.GDPpc), nBins);
   
   % Identify rich countries that do not diversity
   %maskRichUndiverse = false(height(countryData), 1);
   maskRichUndiverse = (countryData.Z < 0.4) & (countryData.ECIstar > -0.25);
   
   % Compute mean diversity and GDP in each bin
   meanGDPpc_byBin     = zeros(nBins,1);
   meanDiversity_byBin = zeros(nBins,1);
   for iBin = 1:nBins
      meanGDPpc_byBin(iBin)     = mean( countryData.GDPpc(binIndices == iBin & ~maskRichUndiverse) );
      meanDiversity_byBin(iBin) = mean( countryData.diversity(binIndices == iBin & ~maskRichUndiverse) );
      meanGini_byBin(iBin)      = mean( countryData.gini(binIndices == iBin & ~maskRichUndiverse) );
   end
end

%========================================================================%
% Fit speed data to a surface
%========================================================================%
% Non-parametrically fit speed data to a surface
if false
   speed           = sqrt(mean_dA.^2 + mean_dECI.^2) / Delta_t;
   [Agrid,ECIgrid] = meshgrid(Acenters, ECIcenters);
   Xfit            = [Agrid(:) ECIgrid(:)];
   Zfit            = speed(:);
   
   mask            = ~isnan(Zfit);
   Xfit            = Xfit(mask,:);
   Zfit            = Zfit(mask);
   
   fitType         = 'lowess';
   speedFitObj     = fit(Xfit, Zfit, fitType);
   save('./save/speedFit.mat','speedFitObj')
else
   load('./save/speedFit.mat')
end


%========================================================================%
% Create plot
%========================================================================%
% Additional or customized appearance parameters
fontSize         = 16;
axes_x1          = 80;
axes_y1          = 70;
axes_width1      = 342;
axes_height1     = 294;
axes_x2          = axes_x1 + axes_width1;
axes_y2          = axes_y1;
axes_width2      = axes_width1;
axes_height2     = axes_height1;

xLim             = [0 1.05];
yLim             = [-1.5 1];

bandColor        = 1*[1 1 1];
bandAlpha        = 0.0;
bandLineStyle    = ':';
bandLineColor    = 0.6*[1 1 1];
bandLineWidth    = 2;

arrowScaling     = 3; %3
arrowColor       = 'k';
arrowLineWidth   = 1.0;

region1Color     = 0.9*[0 0 1];
region1Alpha     = 0.12;
region2Color     = 0.9*[1 0 0];
region2Alpha     = 0.12;
region3Color     = 0.9*[1 1 0];
region3Alpha     = 0.12;
region2TextColor = [253 224 224]/255;
region3TextColor = [252 252 224]/255;

lineDensity      = 8;
lineWidth        = 0.5;
lineColor        = 'b';
arrowSetting     = 'arrows';  %arrows noarrows
speedScale       = 0.3;

text_x1          = 0.65;
text_y1          = -1.2;
text_x2          = 0.9;
text_y2          = 0.65;
text_x3          = 0.05;
text_y3          = 0.85;

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 800   420])


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Quiver plot 
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','Pixels', 'Position', [axes_x1 axes_y1 axes_width1 axes_height1])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
fill(Xregion1, Yregion1, region1Color, 'FaceAlpha',region1Alpha)
fill(Xregion2, Yregion2, region2Color, 'FaceAlpha',region2Alpha)
fill(Xregion3, Yregion3, region3Color, 'FaceAlpha',region3Alpha)

plot(xLim,[0 0],'k--')
h = quiver(Acenters, ECIcenters, mean_dA', mean_dECI', arrowScaling, 'Color',arrowColor, 'LineWidth',arrowLineWidth);
%SetQuiverColor(h,jet)

fill(XV, YV, bandColor, 'FaceAlpha',bandAlpha, 'LineStyle',bandLineStyle, 'EdgeColor',bandLineColor, 'LineWidth',bandLineWidth)
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'FontSize',fontSize)
xlabel('Average ability coordinate A')
ylabel('Composition coordinate b (ECI*)')

% Segment labels
text(text_x1,text_y1,'Region 1', 'HorizontalAlignment','right', 'FontSize',fontSize)
text(text_x2,text_y2,'Region 2', 'HorizontalAlignment','right', 'FontSize',fontSize, 'BackgroundColor',region2TextColor)
text(text_x3,text_y3,'Region 3', 'HorizontalAlignment','left', 'FontSize',fontSize, 'BackgroundColor',region3TextColor)


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Streamline plot 
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Setup axes
axes('Units','Pixels', 'Position', [axes_x2 axes_y2 axes_width2 axes_height2])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on

% Region fills
fill(Xregion1, Yregion1, region1Color, 'FaceAlpha',region1Alpha)
fill(Xregion2, Yregion2, region2Color, 'FaceAlpha',region2Alpha)
fill(Xregion3, Yregion3, region3Color, 'FaceAlpha',region3Alpha)

% Horizontal axis at ECI = 0
plot(xLim,[0 0],'k--')

% Streamlines
[linePoints, arrowPoints] = streamslice(Acenters, ECIcenters, mean_dA', mean_dECI', lineDensity, arrowSetting);
hstreams = streamslice(Acenters, ECIcenters, mean_dA', mean_dECI', lineDensity,arrowSetting);
set(hstreams, 'LineWidth',lineWidth, 'Color',lineColor)
isoTimePoints(Acenters, ECIcenters, mean_dA', mean_dECI', speedFitObj, lineDensity, speedScale)

% Main diagonal band
fill(XV, YV, bandColor, 'FaceAlpha',bandAlpha, 'LineStyle',bandLineStyle, 'EdgeColor',bandLineColor, 'LineWidth',bandLineWidth)
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
%set(gca, 'XTick',[])
set(gca, 'YTick',[])
consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',fontSize)
xlabel('Average ability coordinate A')

% Segment labels
text(text_x1,text_y1,'Region 1', 'HorizontalAlignment','right', 'FontSize',fontSize)
text(text_x2,text_y2,'Region 2', 'HorizontalAlignment','right', 'FontSize',fontSize, 'BackgroundColor',region2TextColor)
text(text_x3,text_y3,'Region 3 ', 'HorizontalAlignment','left', 'FontSize',fontSize, 'BackgroundColor',region3TextColor)


% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'phaseSpaceMovement';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   
   h.PaperPositionMode = 'auto';
   D = h.PaperPosition;
   h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [D(3) D(4)];
   
   save_image(h, fileName, savemode)
end