function analyzeRCA_distribution()
global pp
announceFunction()

%========================================================================%
% Preprocessing
%========================================================================%

% Load data
if true
   load('./save/rcavector.mat')
end

% Get distribution of raw RCAs
edges       = linspace(0,12000,1000);
[xraw,fraw] = getpdf(rca,edges);

% Construct modlog function
xm = min(rca(rca>0));
s  = (xm - 1)/log(xm);
gmod = zeros(length(rca),1);
gmod(rca>0) = 1 + s*log(rca(rca>0));

% Construct R/(R+1) function ('spec')
gspec = rca./(rca+1);
gspec = gspec / mean(gspec);

% Get distributions of transformed RCAs
[N_mod,xbins_mod]   = hist(gmod,300);
[N_spec,xbins_spec] = hist(gspec,300);

% Report other stats
%mean_g = mean(g)
%prctile(g,95)^2
%max(g)^2

% Fit to power law
%mask = (x > 20) & (fx > 0) & (x < 3000);
%beta = polyfit(log(x(mask)),log(fx(mask)),1)

% Explore criteria to set x0
% if false
% x0List          = logspace(-2,2,20);
% meanList        = zeros(10,1);
% sigmaList       = zeros(10,1);
% skewnessList    = zeros(10,1);
% kurtosisList    = zeros(10,1);
% infoContentList = zeros(10,1);
% for i_x0 = 1:length(x0List)
%    x0                 = x0List(i_x0);
%    g                  = log(1 + rca/x0);
%    g                  = g / mean(g);
%    meanList(i_x0)     = mean(g);
%    sigmaList(i_x0)    = std(g);
%    skewnessList(i_x0) = skewness(g);
%    kurtosisList(i_x0) = kurtosis(g);
%    %infoContentList(i_x0) =
% end
% bimodality = (skewnessList.^2 + 1)./kurtosisList;
% qmetric    = (skewnessList) .* meanList;










%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
%xLim = [-1 1];
yLim = 10.^[0 6.7];
spacingHoriz = 0.02;
spacingVert  = 0.1;
marginBottom = 0.2;
marginLeft = 0.12;
marginRight= 0.05;


% Setup figure
newFigure(mfilename);
clf
%figpos = get(gcf, 'Position');
%set(gcf, 'Position',[figpos(1) figpos(2) 950   250]) %680
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 600   560]) %680

x0List = 10.^[-3 log10(0.115) 0 3];
%x0List = 10.^[-8 -7 -5 -3 -1 0 1 2 3];
%x0List = x0List(end:-1:1);
for i_x0 = 1:length(x0List)
   % Transform RCAs
   x0 = x0List(i_x0);
   g  = log(1 + rca/x0) / log(1 + 1/x0);
   %g  = g / mean(g);    % Normalize to set the mean to 1 always
   
   % Get distribution of transformed RCAs
   [N,xbins] = hist(g,300);
   
   % Setup axes
   %axes('Position',[0.15    0.15    0.7    0.7])
   %set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders
   subaxis(2,2,i_x0, 'SpacingHoriz',spacingHoriz, 'MarginBottom',marginBottom, 'MarginLeft',marginLeft, 'MarginRight',marginRight)%, 'SpacingVert',spacingVert)
   
   % Plot
   hold on
   h_g   = plot(xbins,N,'o', 'MarkerFaceColor',MatlabColors(1));
   %h_mod = plot(xbins_mod,N_mod,'k--', 'LineWidth',2);
   %h_spec = plot(xbins_spec,N_spec,'r--', 'LineWidth',2);
   %plot(xbins,-log(N/length(rca))*1e4,'-')
   hold off
   
   % Refine
   set(gca, 'Box','on')
   %set(gca, 'XScale','log')
   set(gca, 'YScale','log')
   %set(gca, 'XLim',xLim)
   set(gca, 'YLim',yLim)
   %set(gca, 'XTick',[])
   set(gca, 'YTick',10.^[0:6])
   %consistentTickPrecision(gca,'x',1)
   %consistentTickPrecision(gca,'y',1)
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
   switch i_x0
      case 1
         %legend([h_g,h_mod],'g(RCA)', 'modlog(RCA)', 'Location','SouthEast')
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

% subaxis(2,1,1)
% hold on
% plot(x,fx,'o')
% plot(x, exp(beta(2))*x.^beta(1),'k-')
% hold off
% set(gca, 'XScale','log','YScale','log')



%========================================================================%
% Plot criteria as a function of x0
%========================================================================%
if false
   figure(2)
   clf
   hold on
   %plot(x0List,meanList, '-o')
   plot(x0List,sigmaList, '-o')
   %plot(x0List,skewnessList, '-o')
   %plot(x0List,kurtosisList, '-o')
   %plot(x0List,bimodality, '-o')
   %plot(x0List,qmetric,'-')
   hold off
   set(gca, 'XScale','log', 'YScale','log')
end


dumpvars()

