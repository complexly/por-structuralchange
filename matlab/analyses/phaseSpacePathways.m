function phaseSpacePathways()
global pp
announceFunction()

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
Aseries_cell         = {};
ECIseries_cell       = {};
for c = 1:nRegions
   % For this region obtain the time series of Z and ECI
   thisRegion       = uniqueRegionCodes{c};
   tableSubset      = countryData( strcmp(countryData.regionCodes,thisRegion), : );
   tableSubset      = sortrows(tableSubset, 'years');
   AtimeSeries_c    = tableSubset.A;
   ECItimeSeries_c  = tableSubset.ECIstar;
   
   % Other: Record for other analyses
   Aseries_cell         = [Aseries_cell;   AtimeSeries_c  ];
   ECIseries_cell       = [ECIseries_cell; ECItimeSeries_c];
end




%========================================================================%
% Compute diversity and GDP like Imbs and Wacziarg
%========================================================================%

% Bin the GDP data
nBins = 50;
binIndices = discretize(log10(countryData.GDPpc), nBins);

% Identify rich countries that are not diverse
%maskRichUndiverse = false(height(countryData), 1);
maskRichUndiverse = (countryData.A < 0.4) & (countryData.ECIstar > -0.25);

% Compute mean diversity and GDP in each bin
meanGDPpc_byBin     = zeros(nBins,1);
meanDiversity_byBin = zeros(nBins,1);
for iBin = 1:nBins
   meanGDPpc_byBin(iBin)     = mean( countryData.GDPpc(binIndices == iBin & ~maskRichUndiverse) );
   meanDiversity_byBin(iBin) = mean( countryData.diversity(binIndices == iBin & ~maskRichUndiverse) );
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
% Create plot
%========================================================================%
% Additional or customized appearance parameters
fontSize         = 16;

xLim             = [0 1.05];
yLim             = [-1.5 1];

region1Color     = [1 1 1];
region2Color     = [1 1 1];
region3Color     = [1 1 1];
region2TextColor = [1 1 1];
region3TextColor = [1 1 1];

lineWidth        = 1.25;

text_x1          = 0.65;
text_y1          = -1.2;
text_x2          = 0.9;
text_y2          = 0.65;
text_x3          = 0.05;
text_y3          = 0.85;

grey = 0.86*[1 1 1];

lineStyleList = {'-','--','-.'};

regionsToPlot = {
   'AIA','VIR',...         %region 3
   'AGO','BDI',...   %deep south
   'ALB','BRA','EGY','ETH','IDN','BGD','THA'...
   'AUT','BEL','CHE','CHN','DEU','KOR','USA','JPN',...       %developed
    };


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
% selectedMemberships = [];
iSelected       = 0;
for iRegion = 1:nRegions
   regionName = uniqueRegionCodes{iRegion};
   
   if ismember(regionName, regionsToPlot)
      A_i           = Aseries_cell{iRegion};
      ECI_i         = ECIseries_cell{iRegion};
      
      iSelected     = iSelected + 1;   
      thisLineStyle = lineStyleList{ mod(iSelected, length(lineStyleList)) + 1 };
      
      h_i = plot(A_i, ECI_i, '-.', 'LineWidth',lineWidth, 'LineStyle',thisLineStyle);
      
      selectedHandles = [selectedHandles h_i];
      selectedNames   = [selectedNames {regionName}];
   end
end

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

% Legend
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