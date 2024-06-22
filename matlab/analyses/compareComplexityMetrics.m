function compareComplexityMetrics()
% Plots the data.

global pp
announceFunction()

%========================================================================%
% Load data
%========================================================================%
% Load data
% load('./save/countryData.mat')
% A                = countryData.A;
% ECIstar          = countryData.ECIstar;
% ECI              = countryData.ECI;
% diversity        = countryData.divesity;
run_filter_robustness_check = false;
if run_filter_robustness_check
   load(fullfile(pp.dataFolder, 'robustness_check/metric2016.mat'))
else
   load(fullfile(pp.dataFolder, 'metric2016.mat'))
end
fitness2016 = struct1.fitness2016;
eci2016     = struct1.eci2016;
%fitness2017 = struct1.fitness2017;
%eci2017     = struct1.eci2017;
prodAbility = struct1.ability;
diversity   = double(struct1.kc);
X1          = struct1.xc1;
X2          = struct1.xc2;
genepy      = struct1.genepy;
A_p         = struct1.avgrca_p;
A_m         = struct1.avgrca_m;
A_c         = struct1.avgrca_c;
teza_hc     = struct1.hc;
collectKnowhow = struct1.fe;

ECIstar_p   = struct1.proj_p;
ECIstar_m   = struct1.proj_m;
ECIstar_c   = struct1.proj_c;
eci1962     = struct1.eci;
diversity0  = double(struct1.bin);


% Compute all cross correlations between metrics
%tickLabels1 = {'\textsf{Diversity} $d$','A','A^M','A^C','Fitness','X_1', 'ECI','ECI*','ECI*^M','ECI*^C','X_2', 'GENEPY'};
%tickLabels2 = {'Diversity $d$','A','$A^M$','$A^C$','Fitness','$X_1 d$', 'ECI','ECI*','ECI*$^M$','ECI*$^C$','$X_2 / \sqrt{d}$', 'GENEPY'};
%tickLabels3 = {'Diversity $d$','Fitness','$X_1 d$','Prod. Ability','TCS entropic','$A$','$A^M$','$A^C$', 'ECI','$X_2 / \sqrt{d}$','$b$ (ECI*)','$b^M$ (ECI*$^M$)','$b^C$ (ECI*$^C$)', 'GENEPY', 'Collective knowhow'};
tickLabels3 = {'Diversity $d$','Fitness','$X_1 d$','Prod. Ability','TCS entropic','$A$','$A^M$','$A^C$', 'ECI','$b$ (ECI*)','$b^M$ (ECI*$^M$)','$b^C$ (ECI*$^C$)','$X_2 / \sqrt{d}$', 'GENEPY', 'Collective knowhow'};

%dataMatrix1 = [diversity; A_p; A_m; A_c; fitness2017; X1;  eci2017; ECIstar_p; ECIstar_m; ECIstar_c;  X2;   genepy]';
%dataMatrix2 = [diversity; A_p; A_m; A_c; fitness2017; X1 .* diversity;  eci2017; ECIstar_p; ECIstar_m; ECIstar_c;  X2 ./ sqrt(diversity);   genepy]';
dataMatrix3 = [diversity; fitness2016; X1 .* diversity; prodAbility; teza_hc; A_p; A_m; A_c;  eci2016; ECIstar_p; ECIstar_m; ECIstar_c; X2 ./ sqrt(diversity); genepy; collectKnowhow]';


correlationMeasure = 'Pearson'; %Pearson Spearman
%C1          = corr(dataMatrix1, 'type',correlationMeasure);
%C2          = corr(dataMatrix2, 'type',correlationMeasure);
C3          = corr(dataMatrix3, 'type',correlationMeasure);


% Report particular correlations
fitness_A_pearson  = corr(fitness2016',             A_p',       'type','Pearson');
prodAbil_A_pearson = corr(prodAbility',             A_p',       'type','Pearson');
X1mod_A_pearson    = corr((X1 .* diversity)',       A_p',       'type','Pearson');
X2mod_ECIstar_pearson  = corr((X2 ./ sqrt(diversity))', ECIstar_p', 'type','Pearson');

fitness_A_spearman  = corr(fitness2016',             A_p',       'type','Spearman');
prodAbil_A_spearman = corr(prodAbility',             A_p',       'type','Spearman');
X1mod_A_spearman    = corr((X1 .* diversity)',       A_p',       'type','Spearman');
X2mod_ECIstar_spearman  = corr((X2 ./ sqrt(diversity))', ECIstar_p', 'type','Spearman');

disp('Fitness correlations')
disp(fitness_A_pearson)
disp(fitness_A_spearman)
disp(' ')

disp('Production ability correlations')
disp(prodAbil_A_pearson)
disp(prodAbil_A_spearman)
disp(' ')

disp('X1 correlations')
disp(X1mod_A_pearson)
disp(X1mod_A_spearman)
disp(' ')

disp('X2 correlations')
disp(X2mod_ECIstar_pearson)
disp(X2mod_ECIstar_spearman)



%========================================================================%
% Plot 1: Without transformations
%========================================================================%
% Additional or customized appearance parameters
fontSize = 14;
braceLineWidth = 1.5;
y0_axes = 0.06;

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 840   420])

% Setup axes
axes('Position',[0.15    y0_axes    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hColorbar = seematrix(C3);

% Move colorbar
set(hColorbar, 'Position',[0.6989    y0_axes    0.0238    0.7000])

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XTick',[1:length(tickLabels3)], 'XTickLabel',tickLabels3, 'XTickLabelRotation',45)
set(gca, 'YTick',[1:length(tickLabels3)], 'YTickLabel',tickLabels3)
set(gca, 'FontSize',fontSize)
set(gca,'TickLabelInterpreter','latex')
%title(correlationMeasure)

% Draw braces
set(gca, 'Clipping','off')
braceX0    = -3.7;
braceY1    = 1 - 0.4;
braceY2    = 8 + 0.4;
braceY3    = 13 + 0.4;
braceTop1  = [braceX0 braceY1];
braceTop2  = [braceX0 braceY2];
braceBot1  = [braceX0 braceY2+0.2];
braceBot2  = [braceX0 braceY3];
braceWidth = 20;
drawbrace(braceTop1, braceTop2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);
drawbrace(braceBot1, braceBot2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);

% Draw block labels
xNudge  = -1.2;
yLabel1 = (braceY1 + braceY2)/2;
yLabel2 = (braceY2 + braceY3)/2;
text(braceX0+xNudge, yLabel1, 'Diversity-like', 'FontSize',fontSize, 'HorizontalAlignment','right')
%text(braceX0+xNudge, yLabel2, {'ECI','composition-like'}, 'FontSize',fontSize, 'HorizontalAlignment','left')
text(-10.4,   10.4953, {'ECI','Composition-like'}, 'FontSize',fontSize, 'HorizontalAlignment','left')


% Create colorbar limits
set(gca, 'CLim',[0 1])
nColors    = 100;
cmapName   = 'parula';
firstColor = [1 1 1];
lastColor  = MatlabColors(7);
%lastColor  = MatlabColors(6);
cmap       = makeColorMap(nColors, cmapName);
%cmap       = makeColorMap(nColors, firstColor, lastColor);
colormap(cmap);
% nColors      = 100;
% dataLimits   = [0 1];
% displayLimts = [0 1];
% cmap         = parula(nColors);
% colorTick    = [0 : 0.1 : 1];
%h = setColorBar(gca,cmap,dataLimits,displayLimts,colorTick);




% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = ['complexityMetricCorrelations_',correlationMeasure];
   fileName  = fullfile(folder, fileName);
   
   h.PaperPositionMode = 'auto';
   D = h.PaperPosition;
   h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [D(3) D(4)];
   
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end


%========================================================================%
% Plot 3: Check the approximations for individual coordinates
%========================================================================%
if false
   % Additional or customized appearance parameters
   xLim = [-1 1];
   yLim = [-1 1];
   
   % Setup figure
   newFigure( [mfilename,'.b'] );
   clf
   figpos = get(gcf, 'Position');
   set(gcf, 'Position',[figpos(1) figpos(2) 560   420])
   
   % Setup axes
   axes('Position',[0.15    0.15    0.7    0.7])
   set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   
   % Plot
   hold on
   %plot([-1 1], [-1 1], 'k--')
   plot(X2, eci2016 .* sqrt(diversity), 'o')
   hold off
   
   corr(X2', ECIstar_p' .* sqrt(diversity)', 'type',correlationMeasure)
   corr(X2', ECIstar_m' .* sqrt(diversity)', 'type',correlationMeasure)
   corr(X2', ECIstar_c' .* sqrt(diversity)', 'type',correlationMeasure)
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'Layer', 'top')
   %set(gca, 'XScale','log')
   %set(gca, 'YScale','log')
   %set(gca, 'XLim',xLim)
   %set(gca, 'YLim',yLim)
   %set(gca, 'DataAspectRatio', [1 1 1])
   %set(gca, 'XTick',[])
   %set(gca, 'YTick',[])
   %consistentTickPrecision(gca,'x',1)
   %consistentTickPrecision(gca,'y',1)
   set(gca, 'FontSize',pp.fontSize)
   %xlabel('x label')
   %ylabel('y label')
   
   % Save
   if pp.saveFigures
      h         = gcf;
      folder    = pp.outputFolder;
      fileName  = mfilename;
      fileName  = fullfile(folder, fileName);
      savemode  = 'epsc';
      save_image(h, fileName, savemode)
   end
end

dumpvars()