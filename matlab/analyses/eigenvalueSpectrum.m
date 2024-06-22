function eigenvalueSpectrum()

global pp
announceFunction()

%========================================================================%
% Preprocessing
%========================================================================%
% Pearson correlations for first 10 eigenvalues of tilde-Phi^P vs tilde-Phi^M:
%rho_PM = [1, 0.94683886, 0.63361727, 0.77166858, 0.49656162, 0.35659562, 0.41346762, 0.61605408, 0.46563947, 0.46737079]; %finding the best matching eigenvectors from each matrix 
rho_PM = [1, 0.94683886, 0.1967514 , 0.77166858, 0.38565486, 0.33714338, 0.29961019, 0.07925617, 0.01877356, 0.10533433]; %ordering both eignevectors by their respecitive eigenvalues


% Pearson correlations for first 10 eigenvalues of tilde-Phi^P vs tilde-Phi^C:
%rho_PC = [1, 0.87163036, 0.47334575, 0.35057975, 0.4114596 , 0.40347503, 0.48460264, 0.26783183, 0.25332656, 0.29351299]; %finding the best match matching eigenvectors from each matrix 
rho_PC = [1, 0.87163036, 0.15714965, 0.33208095, 0.02665303, 0.13455991, 0.05039233, 0.22650458, 0.0822635 , 0.22910967]; %ordering both eignevectors by their respecitive eigenvalues

% First 20 eigenvalues for Phi^M, Phi^P, Phi^C
evs_Phi_M = [1.        , 0.4236572 , 0.19553241, 0.16220691, 0.11019284, 0.10369163, 0.09987103, 0.08410159, 0.08133331, 0.0762297 , 0.07027782, 0.06219564, 0.06103108, 0.05691779, 0.05424373, 0.04939586, 0.04739268, 0.04228964, 0.04126384, 0.03928071];
evs_Phi_P = [1.        , 0.51575661, 0.29865746, 0.22326263, 0.20968323, 0.19062621, 0.16485272, 0.15002271, 0.146174  , 0.13494724, 0.12732075, 0.12466903, 0.11611263, 0.11452076, 0.11182399, 0.10542476, 0.10349556, 0.099288  , 0.09759051, 0.09380697];
evs_Phi_C = [1.        , 0.07803697, 0.04269485, 0.0265822 , 0.02520278, 0.02337382, 0.02083399, 0.02014575, 0.01923577, 0.01874437, 0.01760799, 0.01668968, 0.01654533, 0.01516277, 0.0151056 , 0.0148473 , 0.0135537 , 0.01322704, 0.01263167, 0.01213297];

% First 20 eigenvalues for L_Phi^M, L_Phi^P, L_Phi^C
evs_L_M = 1 - evs_Phi_M;
evs_L_P = 1 - evs_Phi_P;
evs_L_C = 1 - evs_Phi_C;

% Compute effective rank by a variety of criteria
svs_Phi_M = [1.03644886, 0.44496526, 0.20579411, 0.17452835, 0.12272271, 0.1165607 , 0.11129846, 0.09651461, 0.0914748 , 0.08422852, 0.07656514, 0.07290534, 0.07108965, 0.06797909, 0.06473417, 0.06066226, 0.0566601 , 0.05502083, 0.0516315 , 0.04975651];
svs_Phi_P = [1.09335659, 0.55172272, 0.31645523, 0.24284347, 0.2304434, 0.20806853, 0.17641792, 0.16027483, 0.15590117, 0.14262507, 0.13824021, 0.13271288, 0.12337444, 0.12146892, 0.11843173, 0.11391755, 0.11092219, 0.10707351, 0.10583435, 0.10046252];
svs_Phi_C = [1.00259879, 0.07797357, 0.04272286, 0.02660976, 0.02523455, 0.02339627, 0.0208544 , 0.02016434, 0.01925455, 0.01876037, 0.01762509, 0.01670772, 0.01655824, 0.0151748 , 0.01512483, 0.01486053, 0.01356488, 0.01323583, 0.01264056, 0.01214317];


%BEGIN HERE. PLAY AROUND WITH DIFFERENT CRITERIA.



%========================================================================%
% Plot 1: Correlations of eigenvectors
%========================================================================%
% Additional or customized appearance parameters
n_evs = 10;
xLim = [0.5 n_evs+0.5];
yLim = [0 1.05];
tau = 50;

% Setup figure
newFigure([mfilename, '.correlation']);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   350])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
% subaxis(1,1,1, 'MarginLeft',0.13, 'MarginBottom',0.12)
%set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(rho_PC, '-o', 'MarkerFaceColor',MatlabColors(1), 'DisplayName','\rho(v^P,v^C)')
plot(rho_PM, '-o', 'MarkerFaceColor',MatlabColors(2), 'DisplayName','\rho(v^P,v^M)')
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
set(gca, 'FontSize',pp.fontSize)
xlabel('Eigenvector index \mu')
ylabel({'Pearson correlation', 'of eigenvectors'})

% Legend
legend('box','off')

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'corrEigenvectors';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end




%========================================================================%
% Plot 2: Eigenvalue spectrum and time-scale spectrum
%========================================================================%
% Additional or customized appearance parameters
n_evs = 10;
xLim = [0.5 n_evs+0.5];
yLim = [0 1.05];
tau = 50;

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   350])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
% subaxis(1,1,1, 'MarginLeft',0.13, 'MarginBottom',0.12)
%set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
plot(evs_L_C(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(1), 'DisplayName','\Phi^C')
plot(evs_L_M(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(2), 'DisplayName','\Phi^M')
plot(evs_L_P(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(3), 'DisplayName','\Phi^P')
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
%set(gca, 'XScale','log')
%set(gca, 'YScale','log')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
%set(gca, 'DataAspectRatio', [1 1 1])
%set(gca, 'XTickLabel',[])
%set(gca, 'YTick',[])
set(gca, 'FontSize',pp.fontSize)
xlabel('Eigenvector index \mu')
ylabel('Laplacian eigenvalue \kappa_\mu')

% Legend
legend('Location','southeast', 'box','off')


% % Setup axes
% yLim = [0 110];
% subaxis(2,1,2)
% 
% % Plot
% hold on
% plot(tau ./ evs_L_C(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(1), 'DisplayName','\Phi^C')
% plot(tau ./ evs_L_M(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(2), 'DisplayName','\Phi^M')
% plot(tau ./ evs_L_P(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(3), 'DisplayName','\Phi^P')
% hold off
% 
% % Refine
% set(gca, 'Box','on')
% set(gca, 'Layer', 'top')
% %set(gca, 'XScale','log')
% %set(gca, 'YScale','log')
% set(gca, 'XLim',xLim)
% set(gca, 'YLim',yLim)
% %set(gca, 'DataAspectRatio', [1 1 1])
% %set(gca, 'XTick',[])
% %set(gca, 'YTick',[])
% set(gca, 'FontSize',pp.fontSize)
% xlabel('Eigenvector index \mu')
% ylabel('Presumed time-scale \tau_\mu')



% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'eigenvalueSpectrum';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end

dumpvars()