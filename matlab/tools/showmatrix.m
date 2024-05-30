function theColorbar = showmatrix(M)
% showmatrix(M) displays matrix M


% Display matrix
num_symbols = length( unique(M) );
isBinary    = (num_symbols<=2);
if isBinary
   colormap(gca, [1 1 1; 0 0 0]) %black, white colormap
   image(M,'CDataMapping','scaled')
   
else
   colormap(gca,'default')
   image(M,'CDataMapping','scaled')
   set(gca, 'TickLength',[0 0])
   
end

% Refine
set(gca, 'XAxisLocation','top')
set(gca, 'FontSize',12)
%set(gca, 'DataAspectRatio',[1 1 1])

% Colorbar
colorbarLocation = 'outside';
switch colorbarLocation
   case 'inside'
      theColorbar = colorbar('EastOutside', 'Box','on');
   case 'outside'
      current_units = get(gca, 'Units');
      set(gca, 'Units','normalized');
      axesPos        = get(gca, 'Position');
      theColorbar    = colorbar('manual', 'Box','on');
      xColorbar      = axesPos(1) + axesPos(3) + 0.022;
      yColorbar      = axesPos(2);
      widthColorbar  = 0.022;
      heightColorbar = axesPos(4);
      set(theColorbar, 'Position',[xColorbar yColorbar widthColorbar heightColorbar])
      set(gca, 'Units',current_units)
end
clim        = get(theColorbar, 'Limits');
set(theColorbar, 'Limits',[clim(1)-0.5, clim(2)+0.5] ) % Lower bottom and raise top so that numbers are centered on their colors
if isBinary
   dataMin   = min( double(M(:)) );
   dataMax   = max( double(M(:)) );
   colorTick = [dataMin : dataMax];
   set(theColorbar, 'YTick',colorTick);
end






%cmap_Lambda      = [1 1 1; 0 0 0];
%colormap(gca,cmap_Lambda)

% nColors          = max(Delta(:)+1);
% hueStart         = 2.76;
% hueRots          = 0;
% colorSat         = 3;
% gammaCorr        = 1;
% irange1          = 0.08;
% irange2          = 1;
% domain1          = 0.49;
% domain2          = 1;
% cmap_Delta       = cubehelix(nColors,hueStart,hueRots,colorSat,gammaCorr,[irange2 irange1],[domain2 domain1]);



% Left axes
% axes('Units','pixels', 'Position',[xLeft    yLeft    widthLeft    heightLeft])
% seematrix_mod(Delta)
%dataRange = [0 max(Delta(:))];
%hColorBar = setColorBar(gca,cmap_Delta,dataRange);
%set(hColorBar, 'units','pixels', 'Position',[xLeft_colorMap yLeft_colorMap widthLeft_colorMap heightLeft_colorMap])


% set(gca,'XTickLabel',[], 'YTickLabel',[])
% set(gca,'FontSize',fontSize)
% ylabel('Countries')
% xlabel('Products')