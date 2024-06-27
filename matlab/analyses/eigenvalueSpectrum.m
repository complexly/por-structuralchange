function eigenvalueSpectrum()

global pp
announceFunction()

%========================================================================%
% Preprocessing
%========================================================================%

% load rho_PM, rho_PC, evs_Phi_M, evs_Phi_P, evs_Phi_C
load(fullfile(pp.saveFolder, 'eigenspectrum.mat')) 

% Focus on first 10 eigenvectors
n_evs = 11;
rho_PM = rho_PM(1:n_evs);  % Pearson correlations
rho_PC = rho_PC(1:n_evs);
evs_Phi_M = evs_Phi_M(:,1:n_evs); % Eigenvalues
evs_Phi_P = evs_Phi_P(:,1:n_evs);
evs_Phi_C = evs_Phi_C(:,1:n_evs);

% Adopt sign convention for eigenvectors so that correlations are always positive (i.e. flipping sign of the eigenvector if correlation is negative)
rho_PM = abs(rho_PM);
rho_PC = abs(rho_PC);

% First 20 eigenvalues for L_Phi^M, L_Phi^P, L_Phi^C
evs_L_M = 1 - evs_Phi_M;
evs_L_P = 1 - evs_Phi_P;
evs_L_C = 1 - evs_Phi_C;


%========================================================================%
% Plot 1: Correlations of eigenvectors
%========================================================================%
% Additional or customized appearance parameters
xLim = [0.5 n_evs+0.5];
yLim = [0 1.05];

% Setup figure
newFigure([mfilename, '.correlation']);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   350])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])

% Plot
hold on
plot(rho_PC, '-o', 'MarkerFaceColor',MatlabColors(1), 'DisplayName','\rho(v^P,v^C)')
plot(rho_PM, '-o', 'MarkerFaceColor',MatlabColors(2), 'DisplayName','\rho(v^P,v^M)')
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
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

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   350])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])

% Plot
hold on
plot(evs_L_C(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(1), 'DisplayName','\Phi^C')
plot(evs_L_M(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(2), 'DisplayName','\Phi^M')
plot(evs_L_P(1:n_evs+1), '-o', 'MarkerFaceColor',MatlabColors(3), 'DisplayName','\Phi^P')
hold off

% Refine
set(gca, 'Box','on')
set(gca, 'Layer', 'top')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'FontSize',pp.fontSize)
xlabel('Eigenvector index \mu')
ylabel('Laplacian eigenvalue \kappa_\mu')

% Legend
legend('Location','southeast', 'box','off')


% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'eigenvalueSpectrum';
   fileName  = fullfile(folder, fileName);
   savemode  = 'epsc';
   save_image(h, fileName, savemode)
end