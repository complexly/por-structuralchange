function hLabels = drawContourLabels(contourMatrix,sList)

hLabels    = [];
iContour   = 1;
currentCol = 1;
for iContour = 1:length(sList)
   % Parse contourMatrix
   contourLevel = contourMatrix(1,currentCol);
   nPoints      = contourMatrix(2,currentCol);
   Xpoints      = contourMatrix(1,currentCol+1 : currentCol+nPoints);
   Ypoints      = contourMatrix(2,currentCol+1 : currentCol+nPoints);
   
   % Interpolate the contour at a point s
   if ~isnan( sList(iContour) )
      %s       = 0.9;
      s       = sList(iContour);
      [X0,Y0] = arcLengthInterpolate(Xpoints,Ypoints,s);
      h       = text(X0,Y0,num2str(contourLevel), 'VerticalAlignment','middle', 'HorizontalAlignment','center', 'BackgroundColor','w', 'Margin',0.01);
      hLabels = [hLabels h];
   end
   
   % Move to the next contour
   currentCol   = currentCol + nPoints + 1;
end