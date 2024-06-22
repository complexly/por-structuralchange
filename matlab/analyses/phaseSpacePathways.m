function phaseSpacePathways()
global pp
announceFunction()

%========================================================================%
% Set analysis parameters
%========================================================================%
%Delta_t     = 5;   %amount of time averaging to do
Delta_t     = 20;   %amount of time averaging to do
nbins_A     = 10; %10 25
nbins_ECI   = 12; %12 18
minBinCount = 0;  %6
minAveSpeed = 0.07;

%========================================================================%
% Load data
%========================================================================%
% Load
% if ~pp.HS_robustness_check
if true
   load('./save/countryData.mat')

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

   % Sub-analysis: Why do the quiver and streamline plots look noisier than
   % with SITC data?
   mask_rows = countryData.A >= 0.3 & countryData.A <= 0.5 & countryData.ECIstar >= -0.5 & countryData.ECIstar <= 0.0;
   export_basket_subset = countryData(mask_rows,:);
end





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

Aseries_cell         = {};
ECIseries_cell       = {};
diversitySeries_cell = {};
gdpSeries_cell       = {};
%giniSeries_cell      = {};
for c = 1:nRegions
   % For this region obtain the time series of Z and ECI
   thisRegion       = uniqueRegionCodes{c};
   tableSubset      = countryData( strcmp(countryData.regionCodes,thisRegion), : );
   tableSubset      = sortrows(tableSubset, 'years');
   AtimeSeries_c    = tableSubset.A;
   ECItimeSeries_c  = tableSubset.ECIstar;
   diversityTimeSeries_c = tableSubset.diversity;
   gdpTimeSeries_c       = tableSubset.GDPpc;
   %giniTimeSeries_c      = tableSubset.gini;
   
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

   % Other: Record for other analyses
   Aseries_cell         = [Aseries_cell;   AtimeSeries_c  ];
   ECIseries_cell       = [ECIseries_cell; ECItimeSeries_c];
   diversitySeries_cell = [diversitySeries_cell; diversityTimeSeries_c];
   gdpSeries_cell       = [gdpSeries_cell; gdpTimeSeries_c];
   %giniSeries_cell      = [giniSeries_cell; giniTimeSeries_c];
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

% Compute the standard deviation of velocity in each bin



%========================================================================%
% Compute diversity and GDP like Imbs and Wacziarg
%========================================================================%

% Bin the GDP data
nBins = 50;
[binIndices,binEdges] = discretize(log10(countryData.GDPpc), nBins);

% Identify rich countries that are not diverse
%maskRichUndiverse = false(height(countryData), 1);
maskRichUndiverse = (countryData.A < 0.4) & (countryData.ECIstar > -0.25);

% Compute mean diversity and GDP in each bin
meanGDPpc_byBin     = zeros(nBins,1);
meanDiversity_byBin = zeros(nBins,1);
for iBin = 1:nBins
   meanGDPpc_byBin(iBin)     = mean( countryData.GDPpc(binIndices == iBin & ~maskRichUndiverse) );
   meanDiversity_byBin(iBin) = mean( countryData.diversity(binIndices == iBin & ~maskRichUndiverse) );
   %meanGini_byBin(iBin)      = mean( countryData.gini(binIndices == iBin & ~maskRichUndiverse) );
end


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

region1Color     = [1 1 1];
region1Alpha     = 0;
region2Color     = [1 1 1];
region2Alpha     = 0;
region3Color     = [1 1 1];
region3Alpha     = 0;
region2TextColor = [1 1 1];
region3TextColor = [1 1 1];

lineDensity      = 8;  %8
lineWidth        = 0.5;
color_i        = 'b';
arrowSetting     = 'arrows';  %arrows noarrows
speedScale       = 0.3;

lineWidth        = 1.25;
markerSize       = 7;

text_x1          = 0.65;
text_y1          = -1.2;
text_x2          = 0.9;
text_y2          = 0.65;
text_x3          = 0.05;
text_y3          = 0.85;

grey = 0.86*[1 1 1];

lineStyleList = {'-','--','-.'};

%region 3         'AIA','CYM','VIR'
%region 1 (deep)  'AGO','BDI','BEN'
%region 1 (mid)   'ALB','ARG','BRA','EGY','ETH','IND','QAT','VNM','THA','IDN','BGD','CHL'
%region 2         AUT BEL CHE CHN
%weird            'AUS','RUS'
% regionsToPlot = {
%    'AIA','VIR',...         %region 3
%    'AGO','BDI',...   %deep south
%    'ALB','BRA','EGY','ETH','IDN','BGD','THA'...
%    'AUT','BEL','CHE','CHN','DEU','KOR','USA','JPN',...       %developed
%    %'RUS'
%    };
regionsToPlot = {
   'AIA','VIR',...         %region 3
   'AGO','BDI',...   %deep south
   'ALB','BRA','EGY','ETH','IDN','BGD','THA'...
   'AUT','BEL','CHE','CHN','DEU','KOR','USA','JPN',...       %developed
    };

% fullRegionNames = {
%    'Argentina'
%    'Australia'
%    'Bangladesh'
%    'Bermuda'
%    'Brazil'
%    'China'
%    'Cayman Islands'
%    'Germany'
%    'Egypt'
%    'Ethiopia'
%    'Indonesia'
%    'India'
%    'Japan'
%    'Korea'
%    'Qatar'
%    'Russia'
%    'Saudi Arabia'
%    'Thailand'
%    'United States'
%    'Vietnam'
%    };

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560*2   420*2])

% Setup axes
axes('Position',[0.14    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on

% Horizontal axis at ECI = 0
plot(xLim,[0 0],'k--')

% Streamlines
%hstreams = streamslice(Acenters, ECIcenters, mean_dA', mean_dECI', lineDensity,arrowSetting);
%set(hstreams, 'LineWidth',lineWidth, 'Color',lineColor)

% Main diagonal band
%fill(XV, YV, bandColor, 'FaceAlpha',bandAlpha, 'LineStyle',bandLineStyle, 'EdgeColor',bandLineColor, 'LineWidth',bandLineWidth)

% Grey background lines
for iRegion = 1:nRegions
   A_i   = Aseries_cell{iRegion};
   ECI_i = ECIseries_cell{iRegion};
   plot(A_i, ECI_i, '-', 'Color',grey)
end

% Region fills
fill(Xregion1, Yregion1, region1Color, 'FaceColor','none')
fill(Xregion2, Yregion2, region2Color, 'FaceColor','none')
fill(Xregion3, Yregion3, region3Color, 'FaceColor','none')

% Color highlighted lines
selectedHandles = [];
selectedNames   = [];
selectedMemberships = [];
iSelected       = 0;
for iRegion = 1:nRegions
   regionName = uniqueRegionCodes{iRegion};
   
   if ismember(regionName, regionsToPlot)
      A_i           = Aseries_cell{iRegion};
      ECI_i         = ECIseries_cell{iRegion};
      
      iSelected     = iSelected + 1;   
      thisLineStyle = lineStyleList{ mod(iSelected, length(lineStyleList)) + 1 };
      
      h_i = plot(A_i, ECI_i, '-.', 'LineWidth',lineWidth, 'LineStyle',thisLineStyle);
      
      color_i = get(h_i, 'Color');
      %hPoint_i = plot(A_i(1), ECI_i(1), 'o', 'MarkerFaceColor',color_i, 'MarkerEdgeColor',color_i);
      hPoint_i = plot(A_i(end), ECI_i(end), 'o', 'MarkerFaceColor',color_i, 'MarkerEdgeColor',color_i, 'MarkerSize',markerSize);
      
      selectedHandles = [selectedHandles h_i];
      selectedNames   = [selectedNames {regionName}];
      
%       isRegion1Member = inpolygon(A_i(end), ECI_i(end), Xregion1, Yregion1);
%       isRegion2Member = inpolygon(A_i(end), ECI_i(end), Xregion2, Yregion2);
%       isRegion3Member = inpolygon(A_i(end), ECI_i(end), Xregion3, Yregion3);
%       
%       regionMembership = find([isRegion1Member isRegion2Member isRegion3Member]);
%       selectedMemberships = [selectedMemberships regionMembership];
   end
end

hold off

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
%consistentTickPrecision(gca,'x',1)
%consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',fontSize)
xlabel('Average ability coordinate A')
ylabel('Composition coordinate b (ECI*)')

% Segment labels
text(text_x1,text_y1,'Region 1', 'HorizontalAlignment','right', 'FontSize',fontSize)
text(text_x2,text_y2,'Region 2', 'HorizontalAlignment','right', 'FontSize',fontSize, 'BackgroundColor',region2TextColor)
text(text_x3,text_y3,'Region 3', 'HorizontalAlignment','left', 'FontSize',fontSize, 'BackgroundColor',region3TextColor)

% Legend
%hLegend = legend(selectedHandles, selectedNames, 'Location','SouthEast');
%hLegend = legend(selectedHandles, fullRegionNames, 'Location','SouthEast');
hLegend = legend(selectedHandles, countryCodes_to_Names(selectedNames), 'Location','SouthEast');
set(hLegend, 'Box','off', 'Position',[0.8545    0.4083    0.1295    0.4327])

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'phaseSpacePathways';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   
   h.PaperPositionMode = 'auto';
   D = h.PaperPosition;
   h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [D(3) D(4)];
   
   save_image(h, fileName, savemode)
end




%========================================================================%
% Diversity vs. GDP per capita
%========================================================================%
if false
   % Additional or customized appearance parameters
   xLim = 10.^[2 5.25];
   yLim = [-1 1];
   
   % Setup figure
   newFigure( [mfilename,'.diversity'] );
   clf
   figpos = get(gcf, 'Position');
   set(gcf, 'Position',[figpos(1) figpos(2)  1130         480])
   
   % Setup axes
   axes('Position',[0.15    0.15    0.7    0.7])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   for iRegion = 1:nRegions
      
      diversity_i    = diversitySeries_cell{iRegion};
      GDPperCapita_i = gdpSeries_cell{iRegion};
      
      plot(GDPperCapita_i, diversity_i, '-')
      
      
      deltaDiversity = mean(diversity_i(1:5)) - mean(diversity_i(end-4:end));
      if deltaDiversity < 0
         regionName = uniqueRegionCodes{iRegion}
      end
   end
   
   plot(meanGDPpc_byBin, meanDiversity_byBin, 'k-', 'LineWidth',2)
   hold off
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'Layer', 'top')
   set(gca, 'XScale','log')
   %set(gca, 'YScale','log')
   set(gca, 'XLim',xLim)
   %set(gca, 'YLim',yLim)
   %set(gca, 'DataAspectRatio', [1 1 1])
   %set(gca, 'XTick',[])
   %set(gca, 'YTick',[])
   %consistentTickPrecision(gca,'x',1)
   %consistentTickPrecision(gca,'y',1)
   set(gca, 'FontSize',pp.fontSize)
   xlabel('GDP per capita PPP ($)')
   ylabel('Export diversity d')
   
   % Save
   if pp.saveFigures
      h         = gcf;
      folder    = pp.outputFolder;
      fileName  = 'diversity_GDPperCapita';
      fileName  = fullfile(folder, fileName);
      savemode  = 'epsc';
      save_image(h, fileName, savemode)
   end
   
end


% Note: A plot like the one below might be useful to show that decreases in
% the A coordinate are in fact coming with decreases in the diversity,
% which is less obvious in the main figure if one thinks of an individual
% country's trajectory and superimposes it on the diversity contours in the
% Figure a.  But the issue is just that decreases in diversity happen only
% in a handful of countries, not always ones that move to the left in the
% coordinate A.
% figure(8)
% hold on
% for iRegion = 1:nRegions
%    
%    diversity_i = diversitySeries_cell{iRegion};
%    A_i         = Aseries_cell{iRegion};
%    
%    plot(A_i, diversity_i, '-')
% end
% hold off



dumpvars()

