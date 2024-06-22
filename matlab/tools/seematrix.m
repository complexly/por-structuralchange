function hColorbar = seematrix(M)
% seematrix(M) displays matrix M.

% Identify type of matrix.
num_symbols = length( unique(M) );
binary = (num_symbols<=2);

%if islogical(M) || binary
if binary
   map = [[1 1 1]   %black
          [0 0 0]]; %white
   colormap(gca,map)
   image(M+1,'CDataMapping','scaled')
else
   colormap(gca,'default')
   image(M,'CDataMapping','scaled')
   set(gca, 'TickLength',[0 0])
   hColorbar = colorbar('EastOutside', 'Box','on');
end
set(gca, 'DataAspectRatio',[1 1 1])
set(gca, 'XAxisLocation','top')
%set(gca, 'YDir','reverse')
set(gca, 'FontSize',12)