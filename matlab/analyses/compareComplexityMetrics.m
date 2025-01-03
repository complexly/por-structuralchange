function compareComplexityMetrics()
% Plots the data.

global pp
announceFunction()

%========================================================================%
% Load data
%========================================================================%
% Workaround: First load GDP data to get correlation with X2
load(fullfile(pp.saveFolder, 'countryData.mat'))

% Grab just 2016
countryData = countryData(countryData.years == 2016,:);

% Load metric data
run_filter_robustness_check = false;
if run_filter_robustness_check
   load(fullfile(pp.saveFolder, 'robustness_check/metric2016.mat'))
else
   load(fullfile(pp.saveFolder, 'metric2016.mat'))
end
fitness2016 = struct1.fitness2016;
eci2016     = struct1.eci2016;
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

% Compute cross correlations between metrics
location = 'si'; % main or SI
if strcmp(location, 'main')
   tickLabels = {
      'Diversity $d$',
      'Fitness',
      '$X_1 d$',
      'Prod. Ability',
      'TCS entropic',
      '$A$',
      '$A^M$',
      '$A^C$',
      'ECI',
      '$b$ (ECI*)',
      '$b^M$ (ECI*$^M$)',
      '$b^C$ (ECI*$^C$)',
      '$X_2 / \sqrt{d}$',
      'GENEPY',
      'Collective knowhow'
      };
   dataMatrix = [
      diversity; 
      fitness2016; 
      X1 .* diversity; 
      prodAbility; 
      teza_hc; 
      A_p; 
      A_m; 
      A_c;  
      eci2016; 
      ECIstar_p; 
      ECIstar_m; 
      ECIstar_c; 
      X2 ./ sqrt(diversity); 
      genepy; 
      collectKnowhow
      ]';
   braceX0 = -3.7;
   xNudge1 = 1.2;
   xNudge2 = 6.7;
   n_div_like = 8;
   n_comp_like = 5;
else
   tickLabels = {
      'Diversity $d$',
      'Fitness',
      '$X_1 d$',
      'Prod. Ability',
      'TCS entropic',
      '$A$',
      '$A^M$',
      '$A^C$',
      'ECI',
      '$b$ (ECI*)',
      '$b^M$ (ECI*$^M$)',
      '$b^C$ (ECI*$^C$)',
      '$X_2 / \sqrt{d}$',
      '$X_2$',
      'GENEPY',
      '$X_1$',
      'Collective knowhow'
      };
   dataMatrix = [
      diversity; 
      fitness2016; 
      X1 .* diversity; 
      prodAbility; 
      teza_hc; 
      A_p; 
      A_m; 
      A_c;  
      eci2016; 
      ECIstar_p; 
      ECIstar_m; 
      ECIstar_c; 
      X2 ./ sqrt(diversity); 
      X2;
      genepy; 
      X1; 
      collectKnowhow
      ]';
   n_div_like = 8;
   n_comp_like = 6;
   braceX0 = -4.3;
   xNudge1 = 1.4;
   xNudge2 = 7.6;
end
correlationMeasure = 'Pearson'; %Pearson Spearman
C3          = corr(dataMatrix, 'type',correlationMeasure);

% Report particular correlations
fitness_A_pearson  = corr(fitness2016',             A_p',       'type','Pearson');
prodAbil_A_pearson = corr(prodAbility',             A_p',       'type','Pearson');
X1mod_A_pearson    = corr((X1 .* diversity)',       A_p',       'type','Pearson');
X2mod_ECIstar_pearson  = corr((X2 ./ sqrt(diversity))', ECIstar_p', 'type','Pearson');
X1_GENEPY_pearson = corr(X1', genepy', 'type','Pearson');
X1_diversity_pearson = corr(X1', diversity', 'type','Pearson');
X1_Ap_pearson = corr(X1', A_p', 'type','Pearson');
X2_GENEPY_pearson = corr(X2', genepy', 'type','Pearson');
X2_bp_pearson = corr(X2', ECIstar_p', 'type','Pearson');
Ap_diversity_pearson = corr(A_p', diversity', 'type','Pearson');

fitness_A_spearman  = corr(fitness2016',             A_p',       'type','Spearman');
prodAbil_A_spearman = corr(prodAbility',             A_p',       'type','Spearman');
X1mod_A_spearman    = corr((X1 .* diversity)',       A_p',       'type','Spearman');
X2mod_ECIstar_spearman  = corr((X2 ./ sqrt(diversity))', ECIstar_p', 'type','Spearman');
X1_GENEPY_spearman = corr(X1', genepy', 'type','Spearman');
X1_diversity_spearman = corr(X1', diversity', 'type','Spearman');
X1_Ap_spearman = corr(X1', A_p', 'type','Spearman');
X2_GENEPY_spearman = corr(X2', genepy', 'type','Spearman');
X2_bp_spearman = corr(X2', ECIstar_p', 'type','Spearman');
Ap_diversity_spearman = corr(A_p', diversity', 'type','Spearman');

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

disp('X1 correlations with GENEPY')
disp(['Pearson: ',num2str(X1_GENEPY_pearson)])
disp(['Spearman: ',num2str(X1_GENEPY_spearman)])

disp(' ')
disp('X2 correlations with GENEPY')
disp(['Pearson: ',num2str(X2_GENEPY_pearson)])
disp(['Spearman: ',num2str(X2_GENEPY_spearman)])

disp(' ')
disp('A^p correlations with diversity')
disp(['Pearson: ',num2str(Ap_diversity_pearson)])
disp(['Spearman: ',num2str(Ap_diversity_spearman)])

disp(' ')
disp('X1 correlations with diversity')
disp(['Pearson: ',num2str(X1_diversity_pearson)])
disp(['Spearman: ',num2str(X1_diversity_spearman)])

% disp(' ')
% disp('X1 correlations with A^p')
% disp(['Pearson: ',num2str(X1_Ap_pearson)])
% disp(['Spearman: ',num2str(X1_Ap_spearman)])
% 
% disp(' ')
% disp('X2 correlations with b^p')
% disp(['Pearson: ',num2str(X2_bp_pearson)])
% disp(['Spearman: ',num2str(X2_bp_spearman)])

GDPpc = countryData.GDPpc;
bp_GDPpc_pearson = corr(ECIstar_p', GDPpc, 'type','Pearson', 'rows','complete');
bp_GDPpc_spearman = corr(ECIstar_p', GDPpc, 'type','Spearman', 'rows','complete');
X2_GDPpc_pearson = corr(X2', GDPpc, 'type','Pearson', 'rows','complete');
X2_GDPpc_spearman = corr(X2', GDPpc, 'type','Spearman', 'rows','complete');
disp(' ')
disp('b^p correlations with GDPpc')
disp(['Pearson: ',num2str(bp_GDPpc_pearson)])
disp(['Spearman: ',num2str(bp_GDPpc_spearman)])

disp(' ')
disp('X2 correlations with GDPpc')
disp(['Pearson: ',num2str(X2_GDPpc_pearson)])
disp(['Spearman: ',num2str(X2_GDPpc_spearman)])



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
set(gca, 'XTick',[1:length(tickLabels)], 'XTickLabel',tickLabels, 'XTickLabelRotation',45)
set(gca, 'YTick',[1:length(tickLabels)], 'YTickLabel',tickLabels)
set(gca, 'FontSize',fontSize)
set(gca, 'TickLabelInterpreter','latex')

% Draw braces
set(gca, 'Clipping','off')
n_total = n_div_like + n_comp_like;
braceY1    = 1 - 0.4;
braceY2    = n_div_like + 0.4;
braceY3    = n_total + 0.4;
braceTop1  = [braceX0 braceY1];
braceTop2  = [braceX0 braceY2];
braceBot1  = [braceX0 braceY2+0.2];
braceBot2  = [braceX0 braceY3];
braceWidth = 20;
drawbrace(braceTop1, braceTop2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);
drawbrace(braceBot1, braceBot2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);

% Draw block labels
yLabel1 = (braceY1 + braceY2)/2;
yLabel2 = (braceY2 + braceY3)/2 - 0.4047;
brace_label_loc1 = [braceX0 - xNudge1, yLabel1];
brace_label_loc2 = [braceX0 - xNudge2, yLabel2];
text(brace_label_loc1(1), brace_label_loc1(2), 'Diversity-like', 'FontSize',fontSize, 'HorizontalAlignment','right')
text(brace_label_loc2(1), brace_label_loc2(2), {'ECI','Composition-like'}, 'FontSize',fontSize, 'HorizontalAlignment','left')

% Create colorbar limits
set(gca, 'CLim',[0 1])
nColors    = 100;
cmapName   = 'parula';
cmap       = makeColorMap(nColors, cmapName);
colormap(cmap);


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
