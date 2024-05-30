function isoTimePoints(X,Y, U,V, fitObj, lineDensity, speedScale)

% Get the pathways produced by the built-in streamslice function
[linePoints, arrowPoints] = streamslice(X,Y, U,V, lineDensity);

timeStep = 10;
markerFaceColor = MatlabColors(2);
markerEdgeColor = markerFaceColor;
xNudge          = 0.02;

lineList_toPlot = [4];% 108 210 311 319 910 402 909 491];% 568];% 783 631 663];
%timeList = [0 10 20 30 40 60 80 100];
timeList = [0 10 20 30 60 100];
%timeList = [0 10  30  100];

% Plot these lines with varying thickness
%for iLine = 1:length(linePoints)
for iLine = 1:length(lineList_toPlot)
   lineIndex = lineList_toPlot(iLine);
   
   % Get points for this stream
   thisLinePoints = linePoints{lineIndex};
   Xpoints        = thisLinePoints(:,1);
   Ypoints        = thisLinePoints(:,2);
   
   % Compute its length
   cumulativeArcLength = [0, cumsum( sqrt(diff(Xpoints').^2 + diff(Ypoints').^2) )];
   totalLength         = cumulativeArcLength(end);
   
   
   if totalLength > 0
      % Loop over speed times
      arcLengthTraversed = 0;
      x0                 = Xpoints(1);
      y0                 = Ypoints(1);
      
      % Label the line number
      %text(x0,y0,num2str(iLine))
      
      cumulativeTimeLapse = 0;
      
      %if iLine == 4
      %   text(x0,y0,num2str(cumulativeTimeLapse), 'FontSize',16)
      %end
      
      while (arcLengthTraversed < totalLength) & (cumulativeTimeLapse <= 100)
         % Plot a marker here
         plot(x0,y0,'rs', 'MarkerFaceColor',markerFaceColor, 'MarkerEdgeColor',markerEdgeColor)
         %pause
         
         if (iLine == 1) & ismember(cumulativeTimeLapse, timeList)
            text(x0+xNudge,y0, [num2str(cumulativeTimeLapse),' years'], 'FontSize',16)
         end
         
         % Determine speed at this point and the distance to be covered next
         speed0              = feval(fitObj, x0, y0);
         arcLengthTraversed  = arcLengthTraversed + speed0 * timeStep;
         cumulativeTimeLapse = cumulativeTimeLapse + timeStep;
         
         % Interpolate to find the next (x,y) point
         indexList = [1:size(Xpoints,1)];
         i_of_s    = interp1(cumulativeArcLength, indexList, arcLengthTraversed);
         x0        = interp1(indexList, Xpoints, i_of_s);
         y0        = interp1(indexList, Ypoints, i_of_s);        
      end
      
   end
   
   %pause
   
   %drawnow
end







dumpvars()



%see also
%streamline(XYstreamData)
%streamslice(X,Y, U,V);