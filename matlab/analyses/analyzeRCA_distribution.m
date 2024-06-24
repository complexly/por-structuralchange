function analyzeRCA_distribution()
global pp
announceFunction()

%========================================================================%
% Preprocessing
%========================================================================%

% Load data
if true
   load(fullfile(pp.saveFolder, 'rcavector.mat'))
end


%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
yLim = 10.^[0 6.7];
spacingHoriz = 0.02;
marginBottom = 0.2;
marginLeft = 0.12;
marginRight= 0.05;


% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 600   560]) %680

x0List = 10.^[-3 log10(0.115) 0 3];
for i_x0 = 1:length(x0List)
   % Transform RCAs
   x0 = x0List(i_x0);
   g  = log(1 + rca/x0) / log(1 + 1/x0);
   
   % Get distribution of transformed RCAs
   [N,xbins] = hist(g,300);
   
   % Setup axes
   subaxis(2,2,i_x0, 'SpacingHoriz',spacingHoriz, 'MarginBottom',marginBottom, 'MarginLeft',marginLeft, 'MarginRight',marginRight)
   
   % Plot
   hold on
   plot(xbins,N,'o', 'MarkerFaceColor',MatlabColors(1));
   hold off
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'YScale','log')
   set(gca, 'YLim',yLim)
   set(gca, 'YTick',10.^[0:6])
   set(gca, 'FontSize',12)
   xlabel('Transformed RCA g(R)')
   
   switch i_x0
      case {1,2}
         xlabel('')
   end
   switch i_x0
      case {1,3}
         ylabel('Bin count')
      otherwise
         set(gca, 'YTick',[])
   end
   switch i_x0
      case {7,8,9}
        xlabel('g(R)')
   end
   
   % R0 value label
   xlimits = xlim();
   text(0.6*xlimits(2), 3*10^5, ['R_0 = ',num2str(x0)], 'FontSize',12)
   
end

   % Save
   if pp.saveFigures
      h         = gcf;
      folder    = pp.outputFolder;
      fileName  = 'linToLog_distributions.eps';
      fileName  = fullfile(folder, fileName);
      savemode  = 'epsc';
      save_image(h, fileName, savemode)
   end